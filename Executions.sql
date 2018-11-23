
/* USER */
/* "As a registered/unregistered user, I should be able to ..." */
/* 1. Search for original content by its type OR its category */
EXEC Original_Content_Search 'pictures','sub11' 
/* 2. Search for any contributor by his/her name */
EXEC Contributor_Search 'd m contributor1'
/*3.Allows a future user to create an account on the database while checking his/her type */
DECLARE @out INT;
EXEC Register_User 'Viewer' , 'a@gmail.com','1234','Fadi','Essam','Saad','1997/3/27','w122','education','balabizo',null,null,null,null,null,null,@out;
print @out;
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
EXEC Register_User 'Content Manager' , 'b@gmail.com','1234','Fadi','Essam','Saad','1997/3/27',null,null,null,null,null,9,'2000-12-12',8,10.2,@out3;
go
/*4 Allows Content Manager to enter the type of content he's assigned to*/
EXEC Check_Type 'art' , 5
go
/* 5. Show the contributors in the order of the highest years of experience */
 EXEC Order_Contributor
/* 6. Show the approved original content along with all the information of the contributor who uploaded it. */ 
 EXEC Show_Original_Content 5
/* USER */


/*User*/
/*As a registered user, I should be able to …*/
/*1.Return id of the user upon loging in*/
declare @out4 int;
exec User_login 'a@gmail.com','1234',@out4 out;
print @out4;
select * from UserProject
GO
/*2.Shows all info about a user’s profile*/
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
/*3.Allows user to change his/her info*/
exec Edit_Profile 1 , 'new@gmail.com','123','fadi','essam','saad','1997-3-27',null,null,null,null,null,null,null,null,null
/*4.Allows user to deactivate his/her account*/
exec Deactivate_Profile 2;
select * from UserProject where ID =2
/*5.Shows the event with the specific id @event_id or all coming events if  @event_id=null*/
exec Show_Event 1;
exec Show_event 100;
/*6.shows this specific user’s notifications*/
exec Show_Notification 10;
exec Show_Notification 1000;
/*7.Shows the specific new content of that viewer all all of them if @content_id is null*/
exec Show_New_Content 2,2;
exec Show_New_Content 2,null;





































/* VIEWER */
/* "As a Viewer (registered user), I should be able to ..."  */ 
/* 1. Create an event with all itâs possible information */
DECLARE @event_id INT
 EXEC Viewer_Create_Event 'cairo', '1/1/2019', 'new years event', 'moe', 2, 'cfc', @event_id OUTPUT
 PRINT @event_id
/* 2. Insert link for a photo or video to be used in the event*/
 EXEC Viewer_Upload_Event_Photo 1,'linkPhotos.com'
 EXEC Viewer_Upload_Event_Video 2,'linkVideos.com'
/* 3.  Create an advertisement with the information of an event*/
 EXEC Viewer_Create_Ad_From_Event 1
 /* 4. Apply for an existing request to buy a specified original content(s). ONLY allowed original content to be bought has a rating of 4 or 5 stars*/
 EXEC Apply_Existing_Request 1, 4
/* 5. Apply for a new request along with the information of the needed new content*/ 
 EXEC Apply_New_Request 'first new request', NULL, 1
/* 6. Delete any new request I applied for as long as itâs not in process. Note: As long as the contributor did NOT accept the new request.*/
 EXEC Delete_New_Request 1
/* 7. Review any original content by rating it*/ 
 EXEC Rating_Original_Content 3,5,3
/* 8. Write a comment on the original content*/ 
 EXEC Write_Comment 'great content!', 1, 2, '1/1/2018'
/* 9. Edit my comment on any original content*/ 
 EXEC Edit_Comment 'not so great after all!!!', 1, 2, '1/1/2018', '2/2/2018'
/* 10. Delete my comment*/ 
 EXEC Delete_Comment 1, 2, '2/2/2018'
/* 11. Create an advertisement by providing all the needed information for publicity*/ 
EXEC Create_Ads 3,'maybe','some city'
/* 12. Edit my advertisement*/
EXEC Edit_Ad 4,3, 'new desc','guc'
/* 13. Delete my advertisement */
EXEC Delete_Ads 8
/* 14.Send a message to the contributor*/
EXEC Send_Message 'hey kiddo', 1, 6, 0, '1/1/2018'
/* 15. Show all messages to/from a contributor*/
EXEC Show_Message 5
/* 16. Show the original content having the highest rating*/
EXEC Highest_Rating_Original_Content
/* 17. Assign a contributor to a new request. The viewer can NOT re-apply on a rejected new request even if the contributor is different*/
EXEC Assign_New_Request 2, 5
/* VIEWER */








































/* CONTRIBUTOR */
EXEC  Receive_New_Requests 9,4
EXEC  Respond_New_Request 4,1,9
EXEC  Upload_Original_Content 'type 1','sub11','1',4,'that is the link'
EXEC Upload_New_Content 10,5,'sub11','1','the link again'
EXEC Delete_Content 12
DECLARE @CAN BIT
EXEC Receive_New_Request 4,@CAN

EXEC Delete_Original_Content 1
EXEC Delete_New_Content 4
EXEC Assign_Contributor_Request 10,5

/* CONTRIBUTOR */








































/* STAFF MEMBER */
/* 1- Authorized Reviewer filter Original Content */
EXECUTE reviewer_filter_content 9, 2 ,0
/* 2- Content manager filter original content */
EXECUTE content_manager_filter_content 13,2,1
/* 3- Create a category */
EXECUTE Staff_Create_Category 'new category'
/* 4- Create a subcategory */
EXECUTE Staff_Create_Subcategory '1','new subcategory2'
/* 5- Create a new type */
EXECUTE Staff_Create_Type 'new type'
/* 6- Show original content id and the number of request for each content */
EXECUTE Most_Requested_Content
/* 7- Show number of requests related to content of each category ordered by each working place type */
EXECUTE Workingplace_Category_Relation
/* 8-  Delete a comment on the website */
/* ALEADY EXECUTED ABOVE */
/* 9- Delete Original Content */
EXEC Delete_Original_Content 1
/* 10- Delete New Content */
EXEC Delete_New_Content 4
/* 11- Assign a contributor to a request */
EXECUTE Assign_Contributor_Request 6,11
/* 12- Show a list of contributors to be able to assign one of them to a request */
EXECUTE Show_Possible_Contributors


/* STAFF MEMBER */














