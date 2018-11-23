CREATE DATABASE iEgypt
CREATE TABLE UserProject(
ID INT PRIMARY KEY IDENTITY,
email VARCHAR(50),
deactivationStatus BIT DEFAULT 1,
deactivationDate DATETIME,
first_name VARCHAR(50),
middle_name VARCHAR(50),
last_name VARCHAR(50),
birth_date DATETIME,
age AS (YEAR(CURRENT_TIMESTAMP)-YEAR(birth_date)),
passwordUser VARCHAR(50),
UNIQUE (email)
)

CREATE TABLE Viewer(
ID INT,
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES UserProject ON DELETE CASCADE ON UPDATE CASCADE,
working_place VARCHAR(50),
working_place_type VARCHAR(50),
working_place_description VARCHAR(50)
)

CREATE TABLE Notified_Person(
ID INT PRIMARY KEY IDENTITY
)

CREATE TABLE Contributor(
ID INT,
years_of_experience INT,
notified_id INT,
PRIMARY KEY(ID),
specialization VARCHAR(50),
portfolio_link VARCHAR(50),
FOREIGN KEY(ID) REFERENCES UserProject ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(notified_id) REFERENCES Notified_Person ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Staff(
ID INT,
notified_id INT,
hire_date DATETIME,
working_hours DECIMAL(20,5),
payment_rate DECIMAL(20,5),
total_salary AS (payment_rate*working_hours),
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES UserProject ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(notified_id) REFERENCES Notified_Person ON DELETE CASCADE ON UPDATE CASCADE
)


CREATE TABLE Reviewer(
ID INT,
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES Staff ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE MessageProject(
sent_at DATETIME,
contributor_id INT,
viewer_id INT,
sender_type BIT,
read_at DATETIME,
textProject VARCHAR(8000),
read_status BIT,
PRIMARY KEY (sent_at,contributor_id,viewer_id,sender_type),
FOREIGN KEY(contributor_id) REFERENCES Contributor(ID) ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(viewer_id) REFERENCES Viewer(ID) ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Category(
typeCategory VARCHAR(50),
descriptionCategory VARCHAR(1000),
PRIMARY KEY(typeCategory)
)

CREATE TABLE Sub_Category(
category_type VARCHAR(50),
nameSubCategory VARCHAR(50),
PRIMARY KEY(category_type,nameSubCategory),
FOREIGN KEY(category_type) REFERENCES Category ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Content_type(
typeContent_type VARCHAR(50),
PRIMARY KEY(typeContent_type)
)

CREATE TABLE Content_manager(
ID INT,
typeConManager VARCHAR(50),
PRIMARY KEY(ID),
FOREIGN KEY (ID) REFERENCES Staff ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (typeConManager) REFERENCES Content_type ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Notification_Object(
ID INT PRIMARY KEY IDENTITY
)


CREATE TABLE New_Request(
id INT PRIMARY KEY IDENTITY,
accept_status BIT,
specified BIT,
information VARCHAR(1000),
viewer_id INT,
notif_obj_id INT,
contributor_id INT,
Accepted_at DATETIME,
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(notif_obj_id) REFERENCES Notification_Object ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(contributor_id) REFERENCES Contributor ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Content(
ID INT PRIMARY KEY IDENTITY,
link VARCHAR(50),
uploaded_at DATETIME,
contributor_id INT,
category_type VARCHAR(50),
subcategory_name VARCHAR(50),
typeContent VARCHAR(50),
FOREIGN KEY(category_type,subcategory_name) REFERENCES Sub_Category(category_type,nameSubCategory) ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(contributor_id) REFERENCES Contributor ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(typeContent) REFERENCES Content_type ON DELETE NO ACTION ON UPDATE NO ACTION
)
/* HELPER FOR AVG */
GO
CREATE FUNCTION avgRate (@id int)
RETURNS DECIMAL
AS
BEGIN
DECLARE @out DECIMAL(10,2);
SELECT @out=AVG(Rate)
FROM Rate 
WHERE @id=Rate.original_content_id;
RETURN @out;
END
GO
/* HELPER FOR AVG */
CREATE TABLE Original_Content(
ID INT,
content_manager_id INT,
reviewer_id INT,
review_status BIT,
filter_status BIT,
rating AS dbo.avgRate(ID),
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES Content ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(content_manager_id) REFERENCES Content_manager(ID) ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(reviewer_id) REFERENCES Reviewer ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Existing_Request(
id INT PRIMARY KEY IDENTITY,
original_content_id INT,
viewer_id INT,
FOREIGN KEY(original_content_id) REFERENCES Original_Content ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Rate(
viewer_id INT,
original_content_id INT,
dateRate DATETIME,
rate DECIMAL (10,2) CHECK (rate <= 5 AND rate>=0),
PRIMARY KEY(viewer_id,original_content_id),
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(original_content_id) REFERENCES Original_Content ON DELETE NO ACTION ON UPDATE NO ACTION
)



CREATE TABLE New_Content(
ID INT,
new_request_id INT,
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES Content ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(new_request_id) REFERENCES New_Request ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Comment(
Viewer_id INT,
original_content_id INT,
dateComment DATETIME,
textComment VARCHAR(1000),
PRIMARY KEY(Viewer_id,original_content_id,dateComment),
FOREIGN KEY(Viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(original_content_id) REFERENCES Original_Content ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE EventProject(
id INT PRIMARY KEY IDENTITY,
descriptionEvent VARCHAR(1000),
locationEvent VARCHAR(1000),
city VARCHAR(50),
timeEvent DATETIME,
entertainer VARCHAR(50),
notification_object_id INT,
viewer_id INT,
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(notification_object_id) REFERENCES Notification_Object ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Event_Photos_Link(
event_id INT,
link VARCHAR(100),
PRIMARY KEY(event_id,link),
FOREIGN KEY(event_id) REFERENCES EventProject ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Event_Videos_Link(
event_id INT,
link VARCHAR(100),
PRIMARY KEY(event_id,link),
FOREIGN KEY(event_id) REFERENCES EventProject ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Advertisement(
id INT PRIMARY KEY IDENTITY,
descriptionAd VARCHAR(1000),
locationAd VARCHAR(1000),
event_id INT,
viewer_id INT,
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(event_id) REFERENCES EventProject ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Ads_Video_Link(
advertisement_id INT,
link VARCHAR(100),
PRIMARY KEY(advertisement_id,link),
FOREIGN KEY(advertisement_id) REFERENCES Advertisement ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Ads_Photo_Link(
advertisement_id INT,
link VARCHAR(100),
PRIMARY KEY(advertisement_id,link),
FOREIGN KEY(advertisement_id) REFERENCES Advertisement ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Announcement(
ID INT PRIMARY KEY IDENTITY,
seen_at DATETIME,
sent_at DATETIME,
notified_person_id INT,
notification_object_id INT,
FOREIGN KEY(notified_person_id) REFERENCES Notified_Person ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(notification_object_id) REFERENCES Notification_Object ON DELETE NO ACTION ON UPDATE NO ACTION
)






