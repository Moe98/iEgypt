CREATE DATABASE iEgypt_19
CREATE TABLE [User](
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
FOREIGN KEY(ID) REFERENCES [User] ON DELETE CASCADE ON UPDATE CASCADE,
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
FOREIGN KEY(ID) REFERENCES [User] ON DELETE CASCADE ON UPDATE CASCADE,
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
FOREIGN KEY(ID) REFERENCES [User] ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(notified_id) REFERENCES Notified_Person ON DELETE CASCADE ON UPDATE CASCADE
)


CREATE TABLE Reviewer(
ID INT,
PRIMARY KEY(ID),
FOREIGN KEY(ID) REFERENCES Staff ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE [Message](
sent_at DATETIME,
contributor_id INT,
viewer_id INT,
sender_type BIT,
read_at DATETIME,
text VARCHAR(8000),
read_status BIT,
PRIMARY KEY (sent_at,contributor_id,viewer_id,sender_type),
FOREIGN KEY(contributor_id) REFERENCES Contributor(ID) ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(viewer_id) REFERENCES Viewer(ID) ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Category(
category_type VARCHAR(50),
description VARCHAR(1000),
PRIMARY KEY(category_type)
)

CREATE TABLE Sub_Category(
category_type VARCHAR(50),
name VARCHAR(50),
PRIMARY KEY(category_type,name),
FOREIGN KEY(category_type) REFERENCES Category ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Content_type(
type VARCHAR(50),
PRIMARY KEY(type)
)

CREATE TABLE Content_manager(
ID INT,
type VARCHAR(50),
PRIMARY KEY(ID),
FOREIGN KEY (ID) REFERENCES Staff ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (type) REFERENCES Content_type ON DELETE CASCADE ON UPDATE CASCADE
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
type VARCHAR(50),
FOREIGN KEY(category_type,subcategory_name) REFERENCES Sub_Category(category_type,name) ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(contributor_id) REFERENCES Contributor ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(type) REFERENCES Content_type ON DELETE NO ACTION ON UPDATE NO ACTION
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
date DATETIME,
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
date DATETIME,
text VARCHAR(1000),
PRIMARY KEY(Viewer_id,original_content_id,date),
FOREIGN KEY(Viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(original_content_id) REFERENCES Original_Content ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE [Event](
id INT PRIMARY KEY IDENTITY,
description VARCHAR(1000),
location VARCHAR(1000),
city VARCHAR(50),
time DATETIME,
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
FOREIGN KEY(event_id) REFERENCES [Event] ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Event_Videos_Link(
event_id INT,
link VARCHAR(100),
PRIMARY KEY(event_id,link),
FOREIGN KEY(event_id) REFERENCES [Event] ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Advertisement(
id INT PRIMARY KEY IDENTITY,
description VARCHAR(1000),
location VARCHAR(1000),
event_id INT,
viewer_id INT,
FOREIGN KEY(viewer_id) REFERENCES Viewer ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY(event_id) REFERENCES [Event] ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Ads_Video_Link(
advertisement_id INT,
link VARCHAR(100),
PRIMARY KEY(advertisement_id,link),
FOREIGN KEY(advertisement_id) REFERENCES Advertisement ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE Ads_Photos_Link(
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








/*
DROP Table Announcement;
DROP Table Ads_Photos_Link;
DROP Table Ads_Video_Link;
DROP Table Advertisement;
DROP Table Event_Videos_link;
DROP Table Event_Photos_link;
DROP Table [Event];
DROP Table Rate;
DROP Table Comment;
DROP Table New_Content;
DROP Table New_Request;
DROP Table Existing_Request;
DROP Table Original_Content;
DROP Table Content;
DROP Table Notification_Object;
DROP Table Sub_Category;
DROP Table Category;
DROP Table [Message];
DROP Table Reviewer;
DROP Table Content_manager;
DROP Table Content_type;
DROP Table Staff;
DROP Table Contributor;
DROP Table Viewer;
DROP Table Notified_Person;
DROP Table [User];
DROP DATABASE iEgypt_19
*/

/*


DROP PROCEDURE Original_Content_Search;
DROP PROCEDURE Contributor_Search;
DROP PROCEDURE Register_User;
DROP PROCEDURE Check_Type;
DROP PROCEDURE Order_Contributor;
DROP PROCEDURE Show_Original_Content;

DROP PROCEDURE User_login;
DROP PROCEDURE Show_Profile;
DROP PROCEDURE Edit_Profile;
DROP PROCEDURE Deactivate_Profile;
DROP PROCEDURE Show_Event;
DROP PROCEDURE Show_Notification;
DROP PROCEDURE Show_New_Content;

DROP PROCEDURE Viewer_Create_Event;
DROP PROCEDURE Viewer_Upload_Event_Photo;
DROP PROCEDURE Viewer_Upload_Event_Video;
DROP PROCEDURE Viewer_Create_Ad_From_Event;
DROP PROCEDURE Apply_Existing_Request;
DROP PROCEDURE Apply_New_Request;
DROP PROCEDURE Delete_New_Request;
DROP PROCEDURE Rating_Original_Content;
DROP PROCEDURE Write_Comment;
DROP PROCEDURE Edit_Comment;
DROP PROCEDURE Delete_Comment;
DROP PROCEDURE Create_Ads;
DROP PROCEDURE Edit_Ad;
DROP PROCEDURE Delete_Ads;
DROP PROCEDURE Send_Message;
DROP PROCEDURE Show_Message;
DROP PROCEDURE Highest_Rating_Original_content;
DROP PROCEDURE Assign_New_Request;

DROP PROCEDURE Receive_New_Requests;
DROP PROCEDURE Respond_New_Request;
DROP PROCEDURE Upload_Original_Content;
DROP PROCEDURE Upload_New_Content;
DROP PROCEDURE Delete_Content;
DROP PROCEDURE Receive_New_Request;

DROP PROCEDURE reviewer_filter_content;
DROP PROCEDURE content_manager_filter_content;
DROP PROCEDURE Staff_Create_Category;
DROP PROCEDURE Staff_Create_Subcategory;
DROP PROCEDURE Staff_Create_Type;
DROP PROCEDURE Most_Requested_Content;
DROP PROCEDURE Workingplace_Category_Relation;
DROP PROCEDURE Delete_Original_Content;
DROP PROCEDURE Delete_New_Content;
DROP PROCEDURE Assign_Contributor_Request;
DROP PROCEDURE Show_Possible_Contributors;

*/
