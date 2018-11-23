USE iEgypt
/* USER */
/* "As a registered/unregistered user, I should be able to ..." */
/* 1. Search for original content by its type OR its category */
GO
CREATE PROCEDURE Original_Content_Search @typename VARCHAR(50), @categoryname VARCHAR(50)
AS
SELECT *
FROM Original_Content
INNER JOIN Content
ON Original_Content.ID=Content.ID AND Original_Content.review_status=1 AND Original_Content.filter_status=1
WHERE Content.type=@typename OR Content.subcategory_name=@categoryname
/* 2. Search for any contributor by his/her name */
GO
 CREATE PROCEDURE Contributor_Search @fullname VARCHAR(100)
 AS
 SELECT *
 FROM Contributor
 INNER JOIN [User]
 ON Contributor.ID=[User].ID
 WHERE @fullname LIKE [User].first_name+' '+[User].middle_name+' '+[User].last_name
/*3.Allows a future user to create an account on the database while checking his/her type */
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
insert into Notified_Person default VALUES;
declare @n_id1 int;
set @n_id1 = (select top 1 ID from Notified_Person order by ID desc);
insert into Staff (ID,hire_date,working_hours,payment_rate,notified_id)
values(@user_id,@hire_date,@working_hours,@payment_rate,@n_id1);
insert into Reviewer(ID)
Values (@user_id);
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
GO
/*4 Allows Content Manager to enter the type of content he's assigned to*/
 CREATE PROCEDURE Check_Type 
@typename VARCHAR(50),
@id INT
AS
IF NOT EXISTS(
    SELECT type 
    FROM Content_type
    WHERE type = @typename 
)
BEGIN
INSERT INTO Content_type(type)
values(@typename);
END
UPDATE Content_manager 
SET type = @typename 
WHERE @id = ID;
GO

/* 5. Show the contributors in the order of the highest years of experience */
 GO
 CREATE PROCEDURE Order_Contributor
 AS
 SELECT *
 FROM Contributor
 ORDER BY years_of_experience DESC
/* 6. Show the approved original content along with all the information of the contributor who uploaded it. */ 
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

/* USER */
/*As a registered user, I should be able to ...*/
/*1.Return id of the user upon loging in*/
create procedure User_login
@email varchar(50),
@password varchar(50),
@user_id INT OUTPUT
AS
DECLARE @type varchar(50);
IF exists(select ID from [User] where @email=email and @password=passwordUser)
   BEGIN
   if exists (select * from [User] where deactivationStatus =1 and @email=email and @password=passwordUser)
   BEGIN
   select @user_id = ID
   FROM [User]
   WHERE email=@email AND passwordUser=@password;
   END
   ELSE
   BEGIN
   IF exists (select * from [User] where DATEDIFF(DAY,deactivationDate,GETDATE())>14 and @email=email and @password=passwordUser)
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
/*2.Shows all info about a user's profile*/
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
  if @user_id in (select ID from [User])
  BEGIN
  select @user_id = ID , @email=email , @password = passwordUser ,
  @firstname = first_name ,@middlename =middle_name ,  @lastname =last_name,
  @birth_date = birth_date 
  from [User]
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
/*3.Allows user to change his/her info*/
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
if @user_id in (select ID from [User])
BEGIN
update [User]
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
/*4.Allows user to deactivate his/her account*/
create procedure Deactivate_Profile @user_id INT
AS
UPDATE [User]
SET deactivationStatus = 0, deactivationDate = CURRENT_TIMESTAMP
where ID = @user_id;
GO
/*5.Shows the event with the specific id @event_id or all coming events if  @event_id=null*/
create PROCEDURE Show_Event @event_id INT
AS
if exists(select e.id,u.first_name,u.middle_name,u.last_name,e.description,e.location,
e.city,e.time,e.entertainer,e.notification_object_id,e.viewer_id
FROM [Event] e, Viewer v , [User] u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID)
BEGIN
select e.id,u.first_name,u.middle_name,u.last_name,e.description,e.location,
e.city,e.time,e.entertainer,e.notification_object_id,e.viewer_id
FROM [Event] e, Viewer v ,[User] u
WHERE v.ID = viewer_id and e.id=@event_id and u.ID=v.ID
END
ELSE
BEGIN
if @event_id is null
BEGIN
SELECT e.id,u.first_name,u.middle_name,u.last_name,e.description,e.location,
e.city,e.time,e.entertainer,e.notification_object_id,e.viewer_id
FROM [Event] e , Viewer v ,[User] u
WHERE v.ID = viewer_id and u.ID=v.ID and e.time>= current_timestamp
END
END
/*6.shows this specific user's notifications*/
GO
create procedure Show_Notification @user_id INT
AS
if exists(select u.ID from [User] u,Staff s where u.ID=s.ID and u.ID = @user_id )
   or exists(select u.ID from [User] u,Contributor c where u.ID=c.ID and u.ID = @user_id)
BEGIN
   DECLARE @npid int;
   if exists(select u.ID from [User] u,Staff s where u.ID=s.ID and u.ID = @user_id )
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
/*7.Shows the specific new content of that viewer all all of them if @content_id is null*/
create procedure Show_New_Content @viewer_id INT , @content_id INT
AS
if @viewer_id in(select ID from Viewer)
BEGIN
if @content_id is not NULL
BEGIN
SELECT ct.link, ct.uploaded_at, ct.contributor_id, ct.category_type, ct.subcategory_name , ct.type , u.first_name,u.middle_name,u.last_name,u.ID
from New_Request r , New_Content n , Contributor c ,content ct , [User] u
WHERE n.ID = @content_id and n.new_request_id =r.id  and r.viewer_id=@viewer_id
   and ct.contributor_id = c.ID and u.ID = c.ID and ct.ID = n.ID;
END
ELSE
BEGIN
select ct.link, ct.uploaded_at, ct.contributor_id, ct.category_type, ct.subcategory_name , ct.type , u.first_name,u.middle_name,u.last_name,u.ID
from New_Request r ,New_Content n , Contributor c ,content ct , [User] u
WHERE n.new_request_id =r.id and r.viewer_id=@viewer_id
   and ct.contributor_id = c.ID and u.ID = c.ID and ct.ID = n.ID;
END
END
GO

/* VIEWER */
/* "As a Viewer (registered user), I should be able to ..."  */ 
/* 1. Create an event with all itâs possible information */
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
 INSERT INTO [Event] (city,time,description,entertainer,viewer_id,location,notification_object_id)
 VALUES (@city, @event_date_time,@description,@entertainer,@viewer_id,@location,@notID)
 
 DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM [User] ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM [User] WHERE ID=@i)
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
 FROM [Event]
 ORDER BY ID DESC
 )
 END
 GO 

/* 2. Insert link for a photo or video to be used in the event*/
 GO
 CREATE PROCEDURE Viewer_Upload_Event_Photo @event_id INT, @link VARCHAR(100)
 AS
 INSERT INTO Event_Photos_Link VALUES (@event_id,@link)

 GO
 CREATE PROCEDURE Viewer_Upload_Event_Video @event_id INT , @link VARCHAR(100)
 AS
 INSERT INTO Event_Videos_Link VALUES (@event_id,@link)
/* 3.  Create an advertisement with the information of an event*/
 GO
 CREATE PROCEDURE Viewer_Create_Ad_From_Event @event_id INT 
 AS
 DECLARE @desc VARCHAR(1000)
 DECLARE @loc VARCHAR(100)
 DECLARE @viewer_id INT
 SET @desc=(SELECT description FROM [Event] WHERE id=@event_id)
 SET @loc=(SELECT location FROM [Event] WHERE id=@event_id)
 SET @viewer_id=(SELECT viewer_id FROM [Event] WHERE id=@event_id)
 INSERT INTO Advertisement VALUES(@desc,@loc,@event_id,@viewer_id)
 /* 4. Apply for an existing request to buy a specified original content(s). ONLY allowed original content to be bought has a rating of 4 or 5 stars*/
GO
  CREATE PROCEDURE Apply_Existing_Request @viewer_id INT, @original_content_id INT
 AS
 DECLARE @rating DECIMAL(10,2)
 SET @rating=(SELECT rating FROM Original_Content WHERE @original_content_id=ID)
 IF @rating>=4
 BEGIN
 INSERT INTO Existing_Request VALUES(@original_content_id,@viewer_id)
 END
/* 5. Apply for a new request along with the information of the needed new content*/ 
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
 INSERT INTO New_Request (specified,information,viewer_id,notif_obj_id,contributor_id)
VALUES(1,@information,@viewer_id,@notifId,@contributor_id)
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
 INSERT INTO New_Request (specified,information,viewer_id,notif_obj_id) 
VALUES(0,@information,@viewer_id,@notifId2)
 DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM [User] ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM [User] WHERE ID=@i)
 IF @newI IN (SELECT ID FROM Contributor)
 BEGIN
 INSERT INTO Announcement(sent_at,notified_person_id,notification_object_id)
 VALUES(CURRENT_TIMESTAMP,(SELECT notified_id FROM Contributor WHERE ID=@i),@notifId2)
 END
 SET @i=@i+1
 END
 END
/* 6. Delete any new request I applied for as long as itâs not in process. Note: As long as the contributor did NOT accept the new request.*/
 GO
 CREATE PROCEDURE Delete_New_Request @request_id INT
 AS
 DECLARE @status BIT;
 SELECT @status=accept_status FROM New_Request WHERE id=@request_id
 IF(@status IS NULL or @status=1)
 BEGIN
 DELETE FROM New_Request WHERE id=@request_id
 END
/* 7. Review any original content by rating it*/ 
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
/* 8. Write a comment on the original content*/ 
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
/* 9. Edit my comment on any original content*/ 
GO
 CREATE PROCEDURE Edit_Comment @comment_text VARCHAR(1000), @viewer_id INT, @original_content_id INT, @last_written_time DATETIME, @updated_written_time DATETIME
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 UPDATE Comment
 SET text=@comment_text, date=@updated_written_time
 WHERE Viewer_id=@viewer_id AND original_content_id=@original_content_id  AND date=@last_written_time
 END
 END
/* 10. Delete my comment*/ 
GO
 CREATE PROCEDURE Delete_Comment @viewer_id INT, @original_content_id INT, @written_time DATETIME
 AS
 IF @viewer_id IN (SELECT ID FROM Viewer)
 BEGIN
 IF @original_content_id IN (SELECT ID FROM Original_Content)
 BEGIN
 DELETE Comment
 WHERE Viewer_id=@viewer_id AND original_content_id=@original_content_id AND date=@written_time
 END
 END
/* 11. Create an advertisement by providing all the needed information for publicity*/ 
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
 INSERT INTO [Event](description,location,notification_object_id,viewer_id)
 VALUES(@description,@location,@notID,@viewer_id)
 SET @event_id=(SELECT TOP 1 id FROM [Event] ORDER BY id DESC)
INSERT INTO Advertisement (viewer_id,description,location,event_id)
VALUES (@viewer_id,@description,@location,@event_id)

DECLARE @i INT
 SET @i=1
 DECLARE @max INT
 SET @max=(SELECT TOP 1 ID FROM [User] ORDER BY ID DESC)
 WHILE @i<=@max
 BEGIN
 DECLARE @newI INT
 SET @newI=(SELECT ID FROM [User] WHERE ID=@i)
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
/* 12. Edit my advertisement*/
GO
CREATE PROCEDURE Edit_Ad @ad_id INT, @viewer_id INT, @description VARCHAR(1000), @location VARCHAR(1000)
AS
IF @viewer_id IN (SELECT ID FROM Viewer)
BEGIN
UPDATE Advertisement
SET description=@description, location=@location
WHERE id=@ad_id AND viewer_id=@viewer_id /*CHECK WHETHER WE CAN ADD AD ID OR NOT*/
END
/* 13. Delete my advertisement */
GO
CREATE PROCEDURE Delete_Ads @ad_id INT
AS 
DECLARE @notID INT
DECLARE @event_id INT
IF @ad_id IN (SELECT id FROM Advertisement)
BEGIN
SET @event_id=(SELECT event_id FROM Advertisement WHERE id=@ad_id)
SET @notID=(SELECT notification_object_id FROM [Event] WHERE id=@event_id)
DELETE FROM Announcement WHERE notification_object_id=@notID
/*DELETE FROM [Event] WHERE id=@event_id*/
DELETE FROM Advertisement WHERE id=@ad_id
PRINT @event_id
PRINT @notID
END
/* 14.Send a message to the contributor*/
GO
CREATE PROCEDURE Send_Message @msg_text VARCHAR(8000), @viewer_id INT, @contributor_id INT, @sender_type BIT, @sent_at DATETIME
AS
IF @viewer_id IN (SELECT ID FROM Viewer) AND @contributor_id IN (SELECT ID FROM Contributor)
BEGIN
INSERT INTO [Message] (text,viewer_id,contributor_id,sender_type,sent_at,read_status)
VALUES (@msg_text,@viewer_id,@contributor_id,@sender_type,@sent_at,0)
END
/* 15. Show all messages to/from a contributor*/
GO
CREATE PROCEDURE Show_Message @contributor_id INT
AS
IF @contributor_id IN (SELECT ID FRom Contributor)
BEGIN
SELECT *
FROM [Message]
WHERE contributor_id=@contributor_id
END

/* 16. Show the original content having the highest rating*/
GO
CREATE PROCEDURE Highest_Rating_Original_Content
AS
SELECT TOP 1 *
FROM Original_Content
ORDER BY rating DESC
/* 17. Assign a contributor to a new request. The viewer can NOT re-apply on a rejected new request even if the contributor is different*/
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

/* VIEWER */








/* CONTRIBUTOR */
/*1.Receive new Requests,request_id can be null*/
GO
CREATE PROCEDURE Receive_New_Requests  @request_id INT, @contributor_id INT
AS
IF @contributor_id in(SELECT id from Contributor)
BEGIN
IF @request_id IS NOT NULL
BEGIN
DECLARE @notified_obj INT
SET @notified_obj = (SELECT notif_obj_id FROM New_Request WHERE @request_id = New_Request.id)
DECLARE @seen DATETIME
SET @seen = (SELECT seen_at
FROM Announcement
WHERE Announcement.notified_person_id = @contributor_id AND Announcement.notification_object_id = @notified_obj
)
if @seen is null
update Announcement
SET seen_at = CURRENT_TIMESTAMP
WHERE Announcement.notified_person_id = @contributor_id AND Announcement.notification_object_id = @notified_obj
END
ELSE
BEGIN
SET @seen = (SELECT seen_at
FROM Announcement
WHERE Announcement.notified_person_id = @contributor_id 
)
if @seen is null
update Announcement
SET seen_at = CURRENT_TIMESTAMP
WHERE Announcement.notified_person_id = @contributor_id 
END
END


/*2.Respond_New_Request The contributor can accept or reject any request that he received*/
GO
CREATE PROCEDURE Respond_New_Request  @contributor_id INT , @accept_status BIT , @request_id INT
AS
IF @contributor_id in(SELECT id from Contributor)
BEGIN
DECLARE @accepted BIT,@specified BIT
SET @accepted = (
SELECT New_Request.accept_status
FROM New_Request
where New_Request.id=@request_id
)
SET @specified = (
SELECT New_Request.specified
FROM New_Request
where id=@request_id
)
IF @accepted=0 and @specified=0 and @accept_status=1
BEGIN
UPDATE New_Request
SET accept_status=@accept_status , contributor_id=@contributor_id , accepted_at=CURRENT_TIMESTAMP
where New_Request.id=@request_id 
END
IF @accepted=0 and @specified=1
BEGIN
DECLARE @ContID INT
SET @ContID =(
SELECT contributor_id
FROM New_Request
where id=@request_id)
IF @contID=@contributor_id
BEGIN
IF @accept_status=1
BEGIN
UPDATE New_Request
SET accept_status=@accept_status , accepted_at=CURRENT_TIMESTAMP
where id=@request_id
END
ELSE 
UPDATE New_Request
SET accept_status=@accept_status 
where id=@request_id
END
END
END

/*3. Upload_Original_Content The contributor can upload original content */
GO
CREATE PROCEDURE Upload_Original_Content  @type_id VARCHAR(50), @subcategory_name VARCHAR(50), @category_id VARCHAR(50), @contributor_id INT, @link VARCHAR(50)
AS
IF @contributor_id in (SELECT id FROM Contributor)
BEGIN
DECLARE @cid INT
SET @cid =(
SELECT max(ID)
FROM Content
)
SET @cid=@cid+1
SET IDENTITY_INSERT Content ON
INSERT INTO Content(id,link,uploaded_at,contributor_id,category_type,subcategory_name,type)
VALUES(@cid,@link,CURRENT_TIMESTAMP,@contributor_id,@category_id,@subcategory_name,@type_id)
SET IDENTITY_INSERT Content OFF
INSERT INTO Original_Content (ID)
VALUES (@cid)
END
/*4.Upload_New_Content The contributor can upload new content*/
GO
CREATE PROCEDURE Upload_New_Content @new_request_id INT, @contributor_id INT , @subcategory_name VARCHAR(50), @category_id VARCHAR(50),@link VARCHAR(50)
AS
IF @contributor_id in(SELECT ID FROM Contributor)
BEGIN
DECLARE @cid INT
SET @cid=(
SELECT max(ID)
FROM Content
)
SET @cid=@cid+1
SET IDENTITY_INSERT Content ON
INSERT INTO Content(id,link,uploaded_at,contributor_id,category_type,subcategory_name) 
VALUES(@cid,@link,CURRENT_TIMESTAMP,@contributor_id,@category_id,@subcategory_name)
SET IDENTITY_INSERT Content OFF
INSERT INTO New_Content(ID,new_request_id)
VALUES(@cid,@new_request_id)
END
/*5.Delete_Content*/
GO
CREATE PROCEDURE Delete_Content @content_id INT
AS
IF @content_id IN (
SELECT ID
FROM New_Content)
BEGIN
 DECLARE @reqID INT 
 set @reqID=(Select new_request_id From New_Content)
 DELETE 
 FROM New_Content
 where ID=@content_id
 DELETE 
 FROM Content
 WHERE ID=@content_id
 Delete 
 FROM New_Request
 Where id=@reqID
END
IF @content_id IN (
SELECT ID
FROM Original_Content)
BEGIN 
DECLARE @reviewer_ID INT
SET @reviewer_ID=(
SELECT reviewer_id
FROM Original_Content
WHERE @content_id=ID)
IF @reviewer_ID is NULL
BEGIN
DELETE
FROM Original_Content
WHERE @content_id=ID
DELETE
FROM Content
WHERE @content_id=ID
END
END

/*6.Receive_New_Request It returns a boolean that shows whether the contributor can receive any new request or not. */
GO
CREATE PROCEDURE Receive_New_Request @contributor_id INT,@can_receive BIT OUTPUT
AS
CREATE TABLE TEMP(
reqID INT
)
INSERT INTO TEMP
SELECT ID
FROM New_Request
where contributor_id=@contributor_id;
DECLARE @numberOfReq INT
SET @numberOfReq=(
 SELECT count(reqID)
 FROM TEMP
 )
 DECLARE @numberOFReqMade INT
 SET @numberOFReqMade=(
 SELECT count(NC.ID)
 FROM New_Content NC
 INNER JOIN TEMP
 on TEMP.reqID=NC.new_request_id
 )
 IF @numberOfReq-@numberOFReqMade<3
 BEGIN
 SET @can_receive=1
 END
 ELSE
 SET @can_receive=0
 DROP TABLE TEMP


/* CONTRIBUTOR */








































/* STAFF MEMBER */
/* 1- Authorized Reviewer filter Original Content */
GO				 
CREATE PROCEDURE reviewer_filter_content @reviewer_id INT, @original_content INT, @status BIT
AS
IF @reviewer_id IN (SELECT ID FROM Reviewer)
BEGIN
UPDATE Original_Content
SET review_status = @status, reviewer_id=@reviewer_id
WHERE ID = @original_content
END

/* 2- Content manager filter original content */
GO
CREATE PROCEDURE content_manager_filter_content @content_manager_id INT, @original_content INT, @status BIT
AS
IF @content_manager_id in (SELECT ID FROM Content_manager)
BEGIN
DECLARE @typeContMan VARCHAR(100)
SET @typeContMan=(SELECT type FROM Content_manager WHERE ID=@content_manager_id)
DECLARE @contentType VARCHAR(100)
SET @contentType=(SELECT type FROM Content WHERE ID=@original_content)
UPDATE Original_Content
SET filter_status = @status,content_manager_id = @content_manager_id
WHERE ID = @original_content and @typeContMan=@contentType
END
/* 3- Create a category */
GO
CREATE PROCEDURE Staﬀ_Create_Category @category_name VARCHAR(50)
AS
IF @category_name NOT IN (SELECT category_type FROM Category)
BEGIN
INSERT INTO Category(category_type)
VALUES(@category_name)
END

/* 4- Create a subcategory */
GO
CREATE PROCEDURE Staﬀ_Create_Subcategory @category_name VARCHAR(50), @subcategory_name VARCHAR(50)
AS
IF @category_name IN (SELECT category_type FROM Category)
BEGIN
IF @subcategory_name NOT IN (SELECT name FROM Categeory WHERE category_type = @category_name)
BEGIN
INSERT INTO Sub_Category(category_type,name)
VALUES (@category_name,@subcategory_name)
END
END

/* 5- Create a new type */
GO
CREATE PROCEDURE Staff_Create_Type @type_name VARCHAR(50)
AS
IF @type_name NOT IN (SELECT type FROM Content_type)
BEGIN
INSERT INTO Content_type (​type​) 
VALUES(@type_name)
END

/* 6- Show original content id and the number of request for each content */
GO
CREATE PROCEDURE Most_Requested_Content
AS
SELECT original_content_id, COUNT(original_content_id) AS 'Number of requests'
FROM Existing_Request
GROUP BY original_content_id
ORDER BY COUNT(original_content_id) desc


/* 7- Show number of requests related to content of each category ordered by each working place type */
GO
CREATE PROCEDURE Workingplace_Category_Relation
AS
SELECT Viewer.working_place_type, Content.category_type, COUNT(Content.category_type) as 'Number of requests'
FROM Existing_Request INNER JOIN Content
ON Existing_Request.original_content_id = Content.ID
INNER JOIN Viewer 
ON Existing_Request.viewer_id = Viewer.ID
GROUP BY Viewer.working_place_type , Content.category_type
UNION
SELECT Viewer.working_place_type, Content.category_type, COUNT(Content.category_type) as 'Number of requests'
FROM New_Content INNER JOIN Content
ON New_Content.ID = Content.ID
INNER JOIN New_Request
ON New_Request.id = New_Content.new_request_id
INNER JOIN Viewer
ON Viewer.ID = New_Request.viewer_id
GROUP BY Viewer.working_place_type , Content.category_type
order by Viewer.working_place_type

/* 8-  Delete a comment on the website */

/* IT IS ALREADY IMPLEMENTED ABOVE WITH THE SAME NAME IN VIEWER: #10 */

/*9. Delete_Original_Content*/
GO
 CREATE PROCEDURE Delete_Original_Content @content_id INT
 AS
  DELETE 
 FROM Original_Content
 where ID=@content_id
 DELETE 
 FROM Content
 WHERE ID=@content_id

/*10 Delete_New_Content*/
GO
 CREATE PROCEDURE Delete_New_Content @content_id INT
 AS
 DECLARE @reqID INT 
 set @reqID=(Select new_request_id From New_Content)
 DELETE 
 FROM New_Content
 where ID=@content_id
 DELETE 
 FROM Content
 WHERE ID=@content_id
 Delete 
 FROM New_Request
 Where id=@reqID

/*11. Assign_Contributor_Request*/
GO 
CREATE PROCEDURE Assign_Contributor_Request @contributor_id INT,@new_request_id INT
 AS 
 DECLARE @specified BIT 
 SET @specified=(
 SELECT specified
 FROM New_Request
 WHERE @new_request_id=New_Request.id and New_Request.contributor_id is null)
 IF @specified=0
 BEGIN
 UPDATE New_Request
 SET contributor_id=@contributor_id
 WHERE @new_request_id=id
 END

























/* 12- Show a list of contributors to be able to assign one of them to a request*/
GO
CREATE FUNCTION AvgRespondRate (@contributor_id INT) 
RETURNS INT
AS
BEGIN
DECLARE @difference INT
SET @difference = (SELECT AVG(DATEDIFF(day,nr.accepted_at,c.uploaded_at))
FROM New_Request nr INNER JOIN New_Content nc ON nr.id=nc.new_request_id INNER JOIN Content c ON c.ID = nc.ID
WHERE @contributor_id = c.contributor_id)
RETURN @difference
END

GO
CREATE FUNCTION numberOfRequests (@contributor_id INT)
RETURNS INT
AS
BEGIN
DECLARE @requests INT
SET @requests = (SELECT COUNT(*) FROM New_Request WHERE New_Request.contributor_id=@contributor_id)
RETURN @requests
END

GO 
CREATE PROCEDURE Show_Possible_Contributors
AS
SELECT c.contributor_id , COUNT(c.contributor_id) AS 'Number of requests'
FROM Contributor INNER JOIN New_Request nr ON Contributor.ID = nr.contributor_id
INNER JOIN New_Content nc ON nr.id = nc.new_request_id
INNER JOIN Content c ON nc.ID = c.ID
GROUP BY c.contributor_id
HAVING (dbo.numberOfRequests(c.contributor_id))-COUNT(c.contributor_id)<3
ORDER BY dbo.AvgRespondRate(c.contributor_id) ASC, COUNT(c.contributor_id) DESC

/* STAFF MEMBER */ 



