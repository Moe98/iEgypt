CREATE DATABASE iEgypt
/*DROP DATABASE iEgypt
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
exec sp_MSforeachtable @command1="print '?'", @command2="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

DROP TABLE UserProject

ALTER TABLE UserProject NOCHECK CONSTRAINT ALL
ALTER TABLE Viewer NOCHECK CONSTRAINT ALL
ALTER TABLE Notified_Person NOCHECK CONSTRAINT ALL
ALTER TABLE Contributor NOCHECK CONSTRAINT ALL
ALTER TABLE Staff NOCHECK CONSTRAINT ALL
ALTER TABLE Content_manager NOCHECK CONSTRAINT ALL
ALTER TABLE Reviewer NOCHECK CONSTRAINT ALL
ALTER TABLE MessageProject NOCHECK CONSTRAINT ALL
ALTER TABLE Category NOCHECK CONSTRAINT ALL
ALTER TABLE Sub_Category NOCHECK CONSTRAINT ALL
ALTER TABLE Content_type NOCHECK CONSTRAINT ALL
ALTER TABLE Notification_Object NOCHECK CONSTRAINT ALL
ALTER TABLE Existing_Request NOCHECK CONSTRAINT ALL
ALTER TABLE New_Request NOCHECK CONSTRAINT ALL
ALTER TABLE Content NOCHECK CONSTRAINT ALL
ALTER TABLE Original_Content NOCHECK CONSTRAINT ALL
ALTER TABLE Rate NOCHECK CONSTRAINT ALL
ALTER TABLE New_Content NOCHECK CONSTRAINT ALL
ALTER TABLE Comment NOCHECK CONSTRAINT ALL
ALTER TABLE EventProject NOCHECK CONSTRAINT ALL
ALTER TABLE Event_Photos_Link NOCHECK CONSTRAINT ALL
ALTER TABLE Advertisement NOCHECK CONSTRAINT ALL
ALTER TABLE Ads_Video_Link NOCHECK CONSTRAINT ALL
ALTER TABLE Announcement NOCHECK CONSTRAINT ALL

ALTER TABLE UserProject CHECK CONSTRAINT ALL
ALTER TABLE Viewer CHECK CONSTRAINT ALL
ALTER TABLE Notified_Person CHECK CONSTRAINT ALL
ALTER TABLE Contributor CHECK CONSTRAINT 
ALTER TABLE Staff CHECK CONSTRAINT ALL
ALTER TABLE Content_manager CHECK CONSTRAINT ALL
ALTER TABLE Reviewer CHECK CONSTRAINT ALL
ALTER TABLE MessageProject CHECK CONSTRAINT ALL
ALTER TABLE Category CHECK CONSTRAINT ALL
ALTER TABLE Sub_Category CHECK CONSTRAINT ALL
ALTER TABLE Content_type CHECK CONSTRAINT ALL
ALTER TABLE Notification_Object CHECK CONSTRAINT ALL
ALTER TABLE Existing_Request CHECK CONSTRAINT ALL
ALTER TABLE New_Request CHECK CONSTRAINT ALL
ALTER TABLE Content CHECK CONSTRAINT ALL
ALTER TABLE Original_Content CHECK CONSTRAINT ALL
ALTER TABLE Rate CHECK CONSTRAINT ALL
ALTER TABLE New_Content CHECK CONSTRAINT ALL
ALTER TABLE Comment CHECK CONSTRAINT ALL
ALTER TABLE EventProject CHECK CONSTRAINT ALL
ALTER TABLE Event_Photos_Link CHECK CONSTRAINT ALL
ALTER TABLE Advertisement CHECK CONSTRAINT ALL
ALTER TABLE Ads_Video_Link CHECK CONSTRAINT ALL
ALTER TABLE Announcement CHECK CONSTRAINT ALL

DROP TABLE UserProject
DROP TABLE Viewer
DROP TABLE Notified_Person
DROP TABLE Contributor
DROP TABLE Staff
DROP TABLE Content_manager
DROP TABLE Reviewer
DROP TABLE MessageProject
DROP TABLE Category
DROP TABLE Sub_Category
DROP TABLE Content_type
DROP TABLE Notification_Object
DROP TABLE Existing_Request
DROP TABLE New_Request
DROP TABLE Content
DROP TABLE Original_Content
DROP TABLE Rate
DROP TABLE New_Content
DROP TABLE Comment
DROP TABLE EventProject
DROP TABLE Event_Photos_Link
DROP TABLE Advertisement
DROP TABLE Ads_Video_Link
DROP TABLE Ads_Photo_Link
DROP TABLE Announcement
*/

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
FOREIGN KEY (typeConManager) REFERENCES Content_type ON DELETE SET NULL ON UPDATE CASCADE
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
CREATE PROCEDURE avggetter @id int ,@out int OUTPUT
as
SELECT @out=AVG(Rate)
FROM Rate 
WHERE @id=Rate.original_content_id

GO
CREATE FUNCTION average (@id int)
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
rating AS dbo.average(ID),
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

GO
 
CREATE PROCEDURE Original_Content_Search @typename VARCHAR(50), @categoryname VARCHAR(50)
AS
SELECT *
FROM Original_Content
INNER JOIN Content
ON Original_Content.ID=Content.ID AND Original_Content.review_status=1 AND Original_Content.filter_status=1
WHERE Content.typeContent=@typename OR Content.subcategory_name=@categoryname
GO

SELECT * FROM Original_Content
SELECT * FROM Content

EXEC Original_Content_Search 'pictures','sub11' 
GO

 CREATE PROCEDURE Contributor_Search @fullname VARCHAR(100)
 AS
 SELECT *
 FROM Contributor
 INNER JOIN UserProject
 ON Contributor.ID=UserProject.ID
 WHERE @fullname LIKE UserProject.first_name+' '+UserProject.middle_name+' '+UserProject.last_name
 GO
 SELECT * FROM UserProject
 EXEC Contributor_Search 'd m contributor1'
 GO
 CREATE PROCEDURE Order_Contributor
 AS
 SELECT *
 FROM Contributor
 ORDER BY years_of_experience DESC
 GO

 EXEC Order_Contributor
 GO
 
 CREATE PROCEDURE Show_Original_Content @contributor_id INT
 AS
 IF @contributor_id IS NOT NULL
 SELECT *
 FROM Original_Content OC
 INNER JOIN Content C
 ON C.ID=OC.ID
 WHERE C.contributor_id=@contributor_id
 ELSE
 SELECT *
 FROM Original_Content
 GO
 
 SELECT * FROM Contributor
 SELECT * FROM Content
 SELECT * FROM Original_Content
 EXEC  Show_Original_Content NULL
 EXEC Show_Original_Content 5


 /* TESTING Fadi's Procedure */
 GO
 create procedure Show_Profile
  @user_id int,
  @email varchar(50) OUTPUT,
  @password varchar(50) OUTPUT,
  @firstname varchar(50) OUTPUT,
  @middlename varchar(50) OUTPUT,
  @lastname varchar(50) OUTPUT,
  @birth_date date OUTPUT,
  @working_place_name varchar(50) OUTPUT, 
  @working_place_type varchar(50) OUTPUT, 
  @wokring_place_description varchar(1000)OUTPUT, 
  @specilization varchar(50) OUTPUT,
  @portofolio_link varchar(50) OUTPUT, 
  @years_experience int OUTPUT, 
  @hire_date date OUTPUT, 
  @working_hours int OUTPUT, 
  @payment_rate decimal(10,10)OUTPUT
  as
  if @user_id in (select ID from UserProject)
  BEGIN
  select @user_id = ID , @email=email , @password = passwordUser ,
  @firstname = first_name ,@middlename =middle_name ,  @lastname =last_name,
  @birth_date = birth_date 
  from UserProject
  where  @user_id =ID;
  SELECT @working_place_name= working_place, @working_place_type =working_place_type,
  @wokring_place_description=working_place_description
  FROM Viewer
  WHERE  @user_id = ID;
  SELECT @hire_date=hire_date,@working_hours=working_hours , @payment_rate = payment_rate
   FROM Staff
   WHERE @user_id = ID;
  SELECT @years_experience =years_of_experience , @specilization=specialization ,
    @portofolio_link = portfolio_link
    FROM Contributor 
    WHERE @user_id= ID;
END
GO

declare @email varchar(50) ;
  declare @password varchar(50) ;
  declare @firstname varchar(50) ;
  declare @middlename varchar(50) ;
  declare @lastname varchar(50) ;
  declare @birth_date date ;
  declare @working_place_name varchar(50); 
  declare @working_place_type varchar(50) ;
  declare @wokring_place_description varchar(1000);
  declare @specilization varchar(50) ;
  declare @portofolio_link varchar(50) ;
  declare @years_experience int ; 
  declare @hire_date date ;
  declare @working_hours int ;
  declare @payment_rate decimal(10,10);
EXEC Show_Profile 1 , @email OUTPUT, @password OUTPUT, @firstname OUTPUT, @middlename OUTPUT,
@lastname OUTPUT, @birth_date OUTPUT, @working_place_name OUTPUT, @working_place_type
OUTPUT, @wokring_place_description OUTPUT, @specilization OUTPUT,
@portofolio_link OUTPUT, @years_experience OUTPUT, @hire_date OUTPUT, @working_hours
OUTPUT, @payment_rate OUTPUT
print @email;
PRINT @password;
PRINT @firstname;
print @middlename ;
PRINT @lastname ;
print @birth_date;
print @working_place_name;
print @working_place_type;
print @wokring_place_description;
print @specilization;
print @portofolio_link;
PRINT @years_experience;
print @hire_date;
print @working_hours ;
print @payment_rate ;

GO
create PROCEDURE Show_Event @event_id INT
AS
if exists(select e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e, Viewer v , UserProject u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID)
BEGIN
select e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e, Viewer v ,UserProject u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID
END
ELSE
BEGIN
if @event_id is null
BEGIN
SELECT e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e , Viewer v ,UserProject u
WHERE v.ID = viewer_id and u.ID=v.ID and e.timeEvent>= current_timestamp
END
END

EXEC Show_Event NULL
SELECT * FROM EventProject
INSERT INTO EventProject VALUES ('vea','feaf','jio','1/1/2017','feam',18,2)
 /* TESTING Fadi's Procedure */

 GO

 /* Viewer */
 
 
 CREATE PROC Viewer_Create_Event @city VARCHAR(50), @event_date_time DATETIME, @description VARCHAR(1000), @entertainer VARCHAR(50), @viewer_id INT, @location VARCHAR(1000), @event_id INT OUTPUT
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 INSERT INTO Notification_Object DEFAULT VALUES
 DECLARE @notID INT
 SET @notID=(
 SELECT TOP 1 ID
 FROM Notification_Object
 ORDER BY ID DESC
 )
 INSERT INTO EventProject (city,timeEvent,descriptionEvent,entertainer,viewer_id,locationEvent,notification_object_id)
 VALUES (@city, @event_date_time,@description,@entertainer,@viewer_id,@location,@notID)
 
 DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM UserProject ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM UserProject WHERE ID=@i)
 IF @newI IN (SELECT ID FROM Contributor)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@i),@notID)
 END
 IF @newI IN (SELECT ID FROM Staff)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Staff WHERE ID=@i),@notID)
 END
 SET @i=@i+1
 END


 SET @event_id=(
 SELECT TOP 1 id
 FROM EventProject
 ORDER BY ID DESC
 )
 END
 GO
 
 /* EXEC Viewer_Create_Event 'cairo', '1/1/2019', 'new years', 'moe', 2, 'cfc' */
 SELECT * FROM EventProject
 SELECT * FROM Announcement
 SELECT * FROM Notification_Object
 /* FIX WHATEVER THIS ERROR IS AND RETURN EVENT_ID AS OUTPUT*/
 DECLARE @event_id INT
 EXEC Viewer_Create_Event 'cairo', '1/1/2019', 'new years event', 'moe', 2, 'cfc', @event_id OUTPUT
 PRINT @event_id

 GO
 CREATE PROCEDURE Viewer_Upload_Event_Photo @event_id INT, @link VARCHAR(100)
 AS
 INSERT INTO Event_Photos_Link VALUES (@event_id,@link)
 GO

 SELECT * FROM EventProject
 SELECT * FROM Event_Photos_Link
 EXEC Viewer_Upload_Event_Photo 1,'linkPhotos.com'

 GO
 CREATE PROCEDURE Viewer_Upload_Event_Video @event_id INT , @link VARCHAR(100)
 AS
 INSERT INTO Event_Videos_Link VALUES (@event_id,@link)
 GO

 SELECT * FROM EventProject
 SELECT * FROM Event_Videos_Link
 EXEC Viewer_Upload_Event_Video 2,'linkVideos.com'

 GO
 CREATE PROCEDURE Viewer_Create_Ad_From_Event @event_id INT 
 AS
 DECLARE @desc VARCHAR(1000)
 DECLARE @loc VARCHAR(100)
 DECLARE @viewer_id INT
 SET @desc=(SELECT descriptionEvent FROM EventProject WHERE id=@event_id)
 SET @loc=(SELECT locationEvent FROM EventProject WHERE id=@event_id)
 SET @viewer_id=(SELECT viewer_id FROM EventProject WHERE id=@event_id)
 INSERT INTO Advertisement VALUES(@desc,@loc,@event_id,@viewer_id)
 GO
 
 EXEC Viewer_Create_Ad_From_Event 1
 SELECT * FROM EventProject
 SELECT * FROM Advertisement
 
 GO
 
 CREATE PROCEDURE Apply_Existing_Request @viewer_id INT, @original_content_id INT
 AS
 DECLARE @rating DECIMAL(10,2)
 SET @rating=(SELECT rating FROM Original_Content WHERE @original_content_id=ID)
 IF @rating>=4
 BEGIN
 INSERT INTO Existing_Request VALUES(@original_content_id,@viewer_id)
 END
 GO
 
 SELECT * FROM Original_Content
 SELECT * FROM Existing_Request
 EXEC Apply_Existing_Request 1, 4

 GO
 CREATE PROCEDURE Apply_New_Request @information VARCHAR(1000), @contributor_id INT, @viewer_id INT
 AS
 IF @contributor_id IS NOT NULL AND @contributor_id IN (SELECT ID FROM Contributor)
 BEGIN
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 INSERT INTO Notification_Object DEFAULT VALUES
 DECLARE @notifId INT
 SET @notifId=(SELECT TOP 1 ID FROM Notification_Object ORDER BY ID DESC)
 INSERT INTO New_Request VALUES(NULL,1,@information,@viewer_id,@notifId,@contributor_id)
 INSERT INTO Announcement (sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@contributor_id),@notifId)
 END
 END   /* HANDLE MAKING AN ANNOUNCEMENT FOR ALL CONTRIBUTORS WHEN NOT SPECIFIED */
 /*IF @contributor_id IS NULL
 BEGIN
 END */
 IF @contributor_id IS NULL
 BEGIN
 INSERT INTO Notification_Object DEFAULT VALUES
 DECLARE @notifId2 INT
 SET @notifId2 = (SELECT TOP 1 ID FROM Notification_Object ORDER BY ID DESC)
 INSERT INTO New_Request VALUES(NULL,0,@information,@viewer_id,@notifId2,NULL)
 DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM UserProject ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM UserProject WHERE ID=@i)
 IF @newI IN (SELECT ID FROM Contributor)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@i),@notifId2)
 END
 SET @i=@i+1
 END
 END
 GO

 EXEC Apply_New_Request 'first new request', NULL, 1
 SELECT * FROM Announcement
 SELECT * FROM Notification_Object
 SELECT * FROM New_Request
 SELECT * FROM Contributor

 GO
 CREATE PROCEDURE Delete_New_Request @request_id INT
 AS
 DECLARE @status BIT;
 SELECT @status=accept_status FROM New_Request WHERE id=@request_id
 IF(@status IS NULL or @status=1)
 BEGIN
 DELETE FROM New_Request WHERE id=@request_id
 END
 GO 
 
 SELECT * FROM New_Request
 EXEC Delete_New_Request 1

 GO
 
 CREATE PROCEDURE Rating_Original_Content @original_content_id INT, @rating_value INT, @viewer_id INT
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 IF @rating_value BETWEEN 0 AND 5
 BEGIN
 INSERT INTO Rate VALUES (@viewer_id,@original_content_id,CURRENT_TIMESTAMP,@rating_value)
 END
 END
 END
 GO
 
 SELECT * FROM Original_Content
 SELECT * FROM Rate
 EXEC Rating_Original_Content 3,5,3
 GO
 CREATE PROCEDURE Write_Comment @comment_text VARCHAR(1000), @viewer_id INT, @original_content_id INT, @written_time DATETIME
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 INSERT INTO Comment VALUES(@viewer_id,@original_content_id,@written_time,@comment_text)
 END
 END
 GO

 SELECT * FROM Original_Content
 EXEC Write_Comment 'great content!', 1, 2, '1/1/2018'
 SELECT * FROM Comment
 GO
 
 CREATE PROCEDURE Edit_Comment @comment_text VARCHAR(1000), @viewer_id INT, @original_content_id INT, @last_written_time DATETIME, @updated_written_time DATETIME
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 UPDATE Comment
 SET textComment=@comment_text, dateComment=@updated_written_time
 WHERE Viewer_id=@viewer_id AND original_content_id=@original_content_id  AND dateComment=@last_written_time
 END
 END
 GO
 
 EXEC Edit_Comment 'not so great after all!!!', 1, 2, '1/1/2018', '2/2/2018'
 SELECT * FROM Comment

 GO
 CREATE PROCEDURE Delete_Comment @viewer_id INT, @original_content_id INT, @written_time DATETIME
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 DELETE Comment
 WHERE Viewer_id=@viewer_id AND original_content_id=@original_content_id AND dateComment=@written_time
 END
 END
 GO
 
 EXEC Delete_Comment 1, 2, '2/2/2018'
 SELECT * FROM Comment

 GO
 CREATE PROCEDURE Create_Ads @viewer_id INT, @description VARCHAR(1000), @location VARCHAR(1000)
 AS
 DECLARE @event_id INT
 DECLARE @notID INT
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 INSERT INTO Notification_Object DEFAULT VALUES
 SET @notID=(
 SELECT TOP 1 ID
 FROM Notification_Object
 ORDER BY ID DESC
 )
 INSERT INTO EventProject(descriptionEvent,locationEvent,notification_object_id,viewer_id)
 VALUES(@description,@location,@notID,@viewer_id)
 SET @event_id=(SELECT TOP 1 id FROM EventProject ORDER BY id DESC)
INSERT INTO Advertisement (viewer_id,descriptionAd,locationAd,event_id)
VALUES (@viewer_id,@description,@location,@event_id)

DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM UserProject ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM UserProject WHERE ID=@i)
 IF @newI IN (SELECT ID FROM Contributor)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@i),@notID)
 END
 IF @newI IN (SELECT ID FROM Staff)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Staff WHERE ID=@i),@notID)
 END
 SET @i=@i+1
 END

END
GO

EXEC Create_Ads 3,'maybe','some city'
SELECT * FROM Advertisement
SELECT * FROM Announcement
GO
/*
 CREATE PROCEDURE Edit_Ad @viewer_id INT, @description VARCHAR(1000), @location VARCHAR(1000)
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
UPDATE Advertisement
END
GO
*/

CREATE PROCEDURE Edit_Ad @ad_id INT, @viewer_id INT, @description VARCHAR(1000), @location VARCHAR(1000)
AS
IF @viewer_id IN (SELECT ID FROM Viewer)
BEGIN
UPDATE Advertisement
SET descriptionAd=@description, locationAd=@location
WHERE id=@ad_id AND viewer_id=@viewer_id /*CHECK WHETHER WE CAN ADD AD ID OR NOT*/
END
GO
SELECT * FROM Advertisement
EXEC Edit_Ad 4,3, 'new desc','guc'
GO

CREATE PROCEDURE Delete_Ads @ad_id INT
AS 
DECLARE @notID INT
DECLARE @event_id INT
IF @ad_id IN (SELECT id FROM Advertisement)
BEGIN
SET @event_id=(SELECT event_id FROM Advertisement WHERE id=@ad_id)
SET @notID=(SELECT notification_object_id FROM EventProject WHERE id=@event_id)
DELETE FROM Announcement WHERE notification_object_id=@notID
/*DELETE FROM EventProject WHERE id=@event_id*/
DELETE FROM Advertisement WHERE id=@ad_id
PRINT @event_id
PRINT @notID
END
GO

EXEC Delete_Ads 8
SELECT * FROM Advertisement
/* SELECT * FROM EventProject /* CANT DELETE FROM HERE? */ */
SELECT * FROM Announcement
GO


CREATE PROCEDURE Send_Message @msg_text VARCHAR(8000), @viewer_id INT, @contributor_id INT, @sender_type BIT, @sent_at DATETIME
AS
IF @viewer_id IN (SELECT ID FROM Viewer) AND @contributor_id IN (SELECT ID FROM Contributor)
BEGIN
INSERT INTO MessageProject (textProject,viewer_id,contributor_id,sender_type,sent_at,read_status)
VALUES (@msg_text,@viewer_id,@contributor_id,@sender_type,@sent_at,0)
END
GO

EXEC Send_Message 'hey kiddo', 1, 6, 0, '1/1/2018'
SELECT * FROM MessageProject
GO

CREATE PROCEDURE Show_Message @contributor_id INT
AS
IF @contributor_id IN (SELECT ID FRom Contributor)
BEGIN
SELECT *
FROM MessageProject
WHERE contributor_id=@contributor_id
END
GO

EXEC Show_Message 5
SELECT * FROM MessageProject
GO

CREATE PROCEDURE Highest_Rating_Original_Content
AS
SELECT TOP 1 *
FROM Original_Content
ORDER BY rating DESC
GO

SELECT * FROM Original_Content
EXEC Highest_Rating_Original_Content

GO
CREATE PROCEDURE Assign_New_Request @request_id INT, @contributor_id INT   /*ASK ABOUT IT*/
AS
DECLARE @status BIT, @viewer_id INT, @specified BIT, @objID INT
SET @status=(SELECT accept_status FROM New_Request WHERE id=@request_id)
SET @viewer_id=(SELECT viewer_id FROM New_Request WHERE id=@request_id)
SET @specified=(SELECT specified FROM New_Request WHERE id=@request_id)
SET @objID=(SELECT notif_obj_id FROM New_Request WHERE id=@request_id)
/* DO I NEED TO MAKE A NEW ANNOUNCEMENT KNOWING THAT ALL PREVIOUS CONTRIBUTORS HAVE BEEN NOTIFIED BEFORE USING THIS NOTIF_OBJ_ID?????*/
IF @status IS NULL
BEGIN
IF @specified!=1   /*WHAT IF HE'S SPECIFIED?????*/
/* ADD ANNOUNCEMENT IF YOU NEED TO MAKE AN ANNOUNCEMENT */
BEGIN
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Announcement VALUES(NULL,CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@contributor_id),@objID+1)
UPDATE New_Request
SET specified=1, contributor_id=@contributor_id
WHERE id=@request_id
END
END
GO

SELECT * FROM New_Request
EXEC Assign_New_Request 2, 5
 /* Viewer */






 GO

 
 CREATE PROCEDURE Check_Type 
@typename VARCHAR(50),
@id INT
AS
IF NOT EXISTS(
    SELECT typeContent_type 
    FROM Content_type
    WHERE typeContent_type = @typename 
)
BEGIN
INSERT INTO Content_type(typeContent_type)
values(@typename);
END
UPDATE Content_manager 
SET typeConManager = @typename 
WHERE @id = ID;
GO


EXEC Check_Type 'balabizo', 11
EXEC Check_Type 'type 3', 12
SELECT * FROM Content_manager CM INNER JOIN UserProject UP ON CM.ID=UP.ID


GO
create procedure Deactivate_Profile @user_id INT
AS
UPDATE UserProject
SET deactivationStatus = 0, deactivationDate=CURRENT_TIMESTAMP
where ID = @user_id;
GO

exec Deactivate_Profile 2;
select * from UserProject where ID = 2
GO
CREATE PROCEDURE Edit_Profile
@user_id int ,
@email VARCHAR(50),
@password VARCHAR(50),
@firstname VARCHAR(50),
@middlename VARCHAR(50),
@lastname VARCHAR(50),
@birth_date date,
@working_place_name VARCHAR(50),
@working_place_type VARCHAR(50),
@wokring_place_description VARCHAR(1000),
@specilization VARCHAR(50),
@portofolio_link VARCHAR(50),
@years_experience int,
@hire_date date,
@working_hours int,
@payment_rate decimal(10,10)
AS
if @user_id in (select ID from UserProject)
BEGIN
update UserProject
SET email =@email , passwordUser=@password,
first_name =@firstname,middle_name = @middlename,
last_name=@lastname,birth_date=@birth_date
where ID = @user_id;
UPDATE Viewer
SET working_place = @working_place_name ,working_place_description=@wokring_place_description,
working_place_type=@working_place_type
where ID = @user_id;
UPDATE Staff
Set hire_date=@hire_date,payment_rate=@payment_rate
where Id = @user_id;
UPDATE Contributor
SET years_of_experience =@years_experience , specialization=@specilization,
portfolio_link=@portofolio_link
where ID = @user_id;
END
GO 


exec Edit_Profile 1 , 'new@gmail.com','123','fadi','essam','saad','1997-3-27',null,null,null,null,null,null,null,null,null
SELECT * FROM UserProject
GO

create PROCEDURE Show_Event @event_id INT
AS
if exists(select e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e, Viewer v , UserProject u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID)
BEGIN
select e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e, Viewer v ,UserProject u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID
END
ELSE
BEGIN
if @event_id IS NULL
BEGIN
SELECT e.id,u.first_name,u.middle_name,u.last_name,e.descriptionEvent,e.locationEvent,
e.city,e.timeEvent,e.entertainer,e.notification_object_id,e.viewer_id
FROM EventProject e , Viewer v ,UserProject u
WHERE v.ID = viewer_id and u.ID=v.ID
END
END

exec Show_Event 1;
exec Show_event NULL;

GO


create procedure Show_Notification @user_id INT
AS
if exists(select u.ID from UserProject u,Staff s where u.ID=s.ID and u.ID = @user_id )
   or exists(select u.ID from UserProject u,Contributor c where u.ID=c.ID and u.ID = @user_id)
BEGIN
   DECLARE @npid int;
   if exists(select u.ID from UserProject u,Staff s where u.ID=s.ID and u.ID = @user_id )
   BEGIN
       select @npid = n.ID
       FROM staff s,Notified_Person n
       WHERE s.notified_id=n.ID and s.ID=@user_id;
   END
   ELSE
   BEGIN
       select @npid = n.ID
       FROM Contributor c,Notified_Person n
       WHERE c.notified_id=n.ID and c.ID=@user_id;
   END
   SELECT *
   FROM Announcement a
   WHERE a.notified_person_id=@npid
   END
GO

SELECT * FROM Announcement
exec Show_Notification 10;
exec Show_Notification 1000;
GO

create procedure Show_New_Content @viewer_id INT , @content_id INT
AS
if @viewer_id in(select ID from Viewer)
BEGIN
if @content_id is not NULL
BEGIN
SELECT ct.link, ct.uploaded_at, ct.contributor_id, ct.category_type, ct.subcategory_name , ct.typeContent , u.first_name,u.middle_name,u.last_name,u.ID
from New_Request r , New_Content n , Contributor c ,content ct , UserProject u
WHERE n.ID = @content_id and n.new_request_id =r.id  and r.viewer_id=@viewer_id
   and ct.contributor_id = c.ID and u.ID = c.ID and ct.ID = n.ID;
END
ELSE
BEGIN
select ct.link, ct.uploaded_at, ct.contributor_id, ct.category_type, ct.subcategory_name , ct.typeContent , u.first_name,u.middle_name,u.last_name,u.ID
from New_Request r ,New_Content n , Contributor c ,content ct , UserProject u
WHERE n.new_request_id =r.id and r.viewer_id=@viewer_id
   and ct.contributor_id = c.ID and u.ID = c.ID and ct.ID = n.ID;
END
END
GO
SELECT * FROM New_Request
exec Show_New_Content 1,NULL;
exec Show_New_Content 2,null;
SELECT * FROM Content
SELECT * FROM New_Content
INSERT INTO New_Content
VALUES
(7,2),(8,2),(6,3)
GO
/* "As a staﬀ member, I should be able to ..." */

/* 1- Authorized Reviewer filter Original Content */
GO
CREATE PROCEDURE reviewer_ﬁlter_content @reviewer_id INT, @original_content INT, @status BIT
AS
UPDATE Orignal_content
SET review_status = @status
WHERE ID = @original_content and reviewer_id = @reviewer_id

/* 2- Content manager filter original content */
GO
CREATE PROCEDURE content_manager_filter_content @content_manager_id INT, @original_content INT, @status BIT
AS
/* handle the same type and show to viewers*/
DECLARE @typeContMan VARCHAR(100)
SET @typeContMan=(SELECT typeConManager FROM Content_manager WHERE ID=@content_manager_id)
DECLARE @contentType VARCHAR(100)
SET @contentType=(SELECT typeContent FROM Content WHERE ID=@original_content)
UPDATE Orignal_content
SET filter_status = @status
WHERE ID = @original_content and content_manager_id = @content_manager_id  and @typeContMan=@contentType

/* 3- Create a category */
GO
CREATE PROCEDURE Staﬀ_Create_Category @category_name VARCHAR(50)
AS
INSERT INTO Category(typeCategory)
VALUES(@category_name)

/* 4- Create a subcategory */
GO
CREATE PROCEDURE Staﬀ_Create_Subcategory @category_name VARCHAR(50), @subcategory_name VARCHAR(50)
AS
INSERT INTO Sub_Category(category_type,nameSubCategory)
VALUES (@category_name,@subcategory_name)

/* 5- Create a new type */
GO
CREATE PROCEDURE Staﬀ_Create_Type @type_name VARCHAR(50)
AS
INSERT INTO Content_type (​typeContent_type​) 
VALUES(@type_name)

/* 6- Show original content id and the number of request for each content */
GO
CREATE PROCEDURE Most_Requested_Content
AS
SELECT original_content_id, COUNT(original_content_id)
FROM Existing_Request
ORDER BY original_content_id desc

/* 7- Show number of requests related to content of each category ordered by each working place type */
GO
CREATE PROCEDURE Workingplace_Category_Relation
AS
SELECT Viewer.working_place_type, Content.category_type, COUNT(Content.category_type) as 'Number of request'
FROM Existing_Request INNER JOIN Content
ON Existing_Request.original_content_id = Content.ID
INNER JOIN Viewer 
ON Existing_Request.viewer_id = Viewer.ID
order by Viewer.working_place_type

/* 8-  Delete a comment on the website */
GO
CREATE PROCEDURE Delete_Comment_Staff @viewer_id INT, @original_content_id INT, @comment_time DATETIME
AS
DELETE FROM Comment WHERE Viewer_id = @viewer_id and original_content_id= @original_content_id and dateComment = @comment_time
GO
/*USER*/

create procedure User_login
@email varchar(50),
@password varchar(50),
@user_id INT OUTPUT
AS
DECLARE @type varchar(50);
IF exists(select ID from UserProject where @email=email and @password=passwordUser)
   BEGIN
   if exists (select * from userProject where deactivationStatus =1 and @email=email and @password=passwordUser)
   BEGIN
   select @user_id = ID
   FROM UserProject
   WHERE email=@email AND passwordUser=@password;
   END
   ELSE
   BEGIN
   IF exists (select * from userProject where DATEDIFF(DAY,deactivationDate,GETDATE())>14 and @email=email and @password=passwordUser)
   BEGIN
   set @user_id = -1;
   END
   END
   END
ELSE
   BEGIN SET @user_id =-1 ; END
if @user_id <> -1
BEGIN
if exists(select * from Viewer where @user_id = ID)
BEGIN
set @type='Viewer';
END
ELSE
BEGIN
if exists(select * from Contributor where @user_id = ID)
BEGIN
set @type='Contributor';
END
ELSE
BEGIN
if exists(select * from Content_manager where @user_id = ID)
BEGIN
set @type='Content manager';
END
ELSE
BEGIN
if exists(select * from Reviewer where @user_id = ID)
BEGIN
set @type='Authorised Reviewer';
END
END
END
END
END
GO

declare @out4 int;
exec User_login 'a@gmail.com','1234',@out4 out;
print @out4;

SELECT * FROM UserProject
GO
CREATE PROCEDURE Register_User
@usertype VARCHAR(50),
@email VARCHAR(50),
@passwordUser VARCHAR(50),
@first_name VARCHAR(50),
@middle_name VARCHAR(50),
@last_name VARCHAR(50),
@birth_date DATE,
@working_place_name VARCHAR(50),
@working_place_type VARCHAR(50),
@wokring_place_description VARCHAR(1000),
@specialization VARCHAR(50),
@portofolio_link VARCHAR(50),
@years_of_experience INT,
@hire_date DATE,
@working_hours INT,
@payment_rate DECIMAL(10,2),
@user_id INT OUTPUT
AS
insert into UserProject (email,passwordUser,first_name,middle_name,last_name,birth_date)
values(@email,@passwordUser,@first_name,@middle_name,@last_name,@birth_date)
set @user_id=(select top 1 ID from UserProject order by ID desc)
if @usertype = 'Viewer'
insert into Viewer(ID,working_place,working_place_type,working_place_description)
values
(@user_id,@working_place_name,@working_place_type,@wokring_place_description)
else
BEGIN
if( @usertype = 'Contributor')
BEGIN
insert into Notified_Person default VALUES;
declare @n_id int;
set @n_id = (select top 1 ID from Notified_Person order by ID desc);
insert into Contributor(ID,years_of_experience,specialization,portfolio_link,notified_id)
values
(@user_id,@years_of_experience,@specialization,@portofolio_link,@n_id);
END
else
BEGIN
if @usertype = 'Authorized Reviewer'
BEGIN
insert into Reviewer(ID)
values
(@user_id);
insert into Notified_Person default VALUES;
declare @n_id1 int;
set @n_id1 = (select top 1 ID from Notified_Person order by ID desc);
insert into Staff (ID,hire_date,working_hours,payment_rate,notified_id)
values(@user_id,@hire_date,@working_hours,@payment_rate,@n_id1);
END
else
BEGIN
if @usertype = 'Content Manager'
insert into Notified_Person default VALUES;
declare @n_id2 int;
set @n_id2 = (select top 1 ID from Notified_Person order by ID desc);
insert into Staff (ID,hire_date,working_hours,payment_rate,notified_id)
values(@user_id,@hire_date,@working_hours,@payment_rate,@n_id2)
insert into Content_manager (ID)
values(@user_id);
END
END
END

/* TESTING REGISTER */
SELECT * FROM UserProject
DECLARE @out INT;
EXEC Register_User 'Authorized Reviewer' , 'abfeafeafeacbc@gmail.com','1234','Fadi','Essam','Saad','1997/3/27','w122','education','balabizo',null,null,null,null,null,null,@out;
print @out;
SELECT * FROM Reviewer R INNER JOIN UserProject UP ON UP.ID=R.ID
GO
select * FROM Viewer
GO
DECLARE @out1 INT;
EXEC Register_User 'Contributor' , 'a@gmail.com','1234','Fadi','Essam','Saad','1997/3/27',null,null,null,'art','link123',9,'2000-12-12',8,10.2,@out1;
print @out1;
GO
select * FROM UserProject
GO
declare @out3 int;
EXEC Register_User 'Content Manager' , 'abfeaaeefafaeafeaeffaec@gmail.com','1234','Fadi','Essam','Saad','1997/3/27',null,null,null,null,null,9,'2000-12-12',8,10.2,@out3;
SELECT * FROM Content_manager CM INNER JOIN UserProject UP ON CM.ID=UP.ID
SELECT * FROM Reviewer R INNER JOIN UserProject UP ON R.ID=UP.ID
/* TESTING REGISTER */


/* INSERTIONS */
/*CATEGORY PART*/
INSERT INTO Category VALUES
('1','its 1'), ('2','its 2'), ('3','its 3')

INSERT INTO Sub_Category VALUES
('1','sub11'), ('1','sub12'), ('2','sub21'), ('2','sub22'), ('3','sub31'), ('3','sub32')

SELECT * FROM Category
SELECT * FROM Sub_Category
/*CATEGORY PART*/

/*USER*/
INSERT INTO UserProject (email,deactivationStatus, first_name,middle_name,last_name,birth_date,passwordUser)
VALUES
('a@gmail.com', 1, 'a','m','viewer1','1/1/1980','12345'), 
('b@gmail.com', 1, 'b','m','viewer2','1/1/1980','12345'),
('c@gmail.com', 1, 'c','m','viewer3','1/1/1980','12345'),
('d@gmail.com', 1, 'd','m','contributor1','1/1/1980','12345'),
('e@gmail.com', 1, 'e','m','contributor2','1/1/1980','12345'),
('f@gmail.com', 1, 'f','m','contributor3','1/1/1980','12345'),
('g@gmail.com', 1, 'g','m','contributor4','1/1/1980','12345'),
('h@gmail.com', 1, 'h','m','contributor5','1/1/1980','12345'),
('i@gmail.com', 1, 'i','m','Reviewer1','1/1/1980','12345'),
('j@gmail.com', 1, 'j','m','Reviewer2','1/1/1980','12345'),
('k@gmail.com', 1, 'k','m','ContMan1','1/1/1980','12345'),
('l@gmail.com', 1, 'l','m','ContMan2','1/1/1980','12345'),
('m@gmail.com', 1, 'm','m','ContMan3','1/1/1980','12345')

SELECT * FROM UserProject
INSERT INTO Viewer(ID,working_place,working_place_type,working_place_description)
VALUES
(1,'wp1','t1','d1'),
(2,'wp2','t2','d2'),
(3,'wp1','t1','d1')

SELECT * FROM Viewer

INSERT INTO Notified_Person DEFAULT VALUES

SELECT * FROM Notified_Person

INSERT INTO Contributor (ID, years_of_experience, portfolio_link, specialization, notified_id)
VALUES
(4,1,'link1@gmail.com','s1',1),
(5,2,'link2@gmail.com','s2',2),
(6,3,'link3@gmail.com','s3',3),
(7,4,'link4@gmail.com','s4',4),
(8,5,'link5@gmail.com','s5',5)

SELECT * FROM Contributor

INSERT INTO Staff (ID, hire_date, working_hours, payment_rate,notified_id)
VALUES
(9,'1/1/1999',3,25,6),
(10,'1/1/2000',3,25,7),
(11,'1/1/2000',3,25,8),
(12,'3/1/2000',4,25,9),
(13,'3/1/2000',4,30,10)

SELECT * FROM Staff

INSERT INTO Reviewer(ID)
VALUES(9),(10)

SELECT * FROM Reviewer

INSERT INTO Content_type VALUES
('type 1'),('type 2'),('type 3')

SELECT * FROM Content_type

INSERT INTO Content_manager VALUES
(11,'type 1'),(12,'type 2'),(13,'type 3')

SELECT * FROM Reviewer

INSERT INTO Content_type
VALUES
('websites'),('pictures'),('videos')

SELECT * FROM Content_type

SELECT * FROM Contributor

SELECT * FROM Sub_Category


INSERT INTO Content 
VALUES
('link1.com','11/11/2018', 4, 1,'sub11','pictures'), ('link2.com','11/12/2018', 5, 2,'sub21','videos'), ('link3.com','10/10/2018', 6, 3,'sub31','videos')
INSERT INTO Content (link,uploaded_at,contributor_id,category_type,subcategory_name,typeContent)
VALUES
('link3.com','10/10/2018', 6, 3,'sub31','videos')

SELECT * FROM Content
INSERT INTO Original_Content (ID,content_manager_id,reviewer_id,review_status,filter_status)VALUES(1,11,9,1,1), (2,12,9,1,1), (3,13,10,1,1), (4,11,10,1,1)SELECT * FROM Original_ContentINSERT INTO Notification_Object DEFAULT VALUESSELECT * FROM Notification_ObjectINSERT INTO EventProjectVALUES('event 1','cfc','cairo','1/1/2019','mark',1,1), ('event 2','guc','cairo','4/3/2019','carol',2,2)SELECT * FROM EventProjectINSERT INTO Advertisement VALUES('ad1','egypt',1,1), ('ad2','germany',2,2)INSERT INTO AnnouncementVALUES(NULL,CURRENT_TIMESTAMP,1,1),(NULL,CURRENT_TIMESTAMP,2,1),(NULL,CURRENT_TIMESTAMP,3,1),(NULL,CURRENT_TIMESTAMP,4,1),(NULL,CURRENT_TIMESTAMP,5,1),(NULL,CURRENT_TIMESTAMP,6,1),(NULL,CURRENT_TIMESTAMP,7,1),(NULL,CURRENT_TIMESTAMP,8,1),(NULL,CURRENT_TIMESTAMP,9,1),(NULL,CURRENT_TIMESTAMP,10,1),(NULL,CURRENT_TIMESTAMP,1,2),(NULL,CURRENT_TIMESTAMP,2,2),(NULL,CURRENT_TIMESTAMP,3,2),(NULL,CURRENT_TIMESTAMP,4,2),(NULL,CURRENT_TIMESTAMP,5,2),(NULL,CURRENT_TIMESTAMP,6,2),(NULL,CURRENT_TIMESTAMP,7,2),(NULL,CURRENT_TIMESTAMP,8,2),(NULL,CURRENT_TIMESTAMP,9,2),(NULL,CURRENT_TIMESTAMP,10,2)INSERT INTO Advertisement (descriptionAd,locationAd,event_id,viewer_id) VALUES ('CFC AD','CFC',1,1),('GUC AD','GUC',2,2)SELECT * FROM Advertisement