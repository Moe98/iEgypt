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
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Notified_Person DEFAULT VALUES
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

SELECT * FROM Content_manager


INSERT INTO Content 
VALUES
('link1.com','11/11/2018', 4, '1','sub11','type 1'), ('link2.com','11/12/2018', 5, '2','sub21','type 2'), ('link3.com','10/10/2018', 6, '3','sub31','type 2')

SELECT * FROM Content

INSERT INTO Original_Content (ID,content_manager_id,reviewer_id)
VALUES
(1,11,9),(2,12,9),(3,13,10)

SELECT * FROM Original_Content

INSERT INTO Content
(link) VALUES ('check thaaat!')

INSERT INTO New_Content(ID)VALUES(4)

INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO Notification_Object DEFAULT VALUES
SELECT * FROM Notification_Object

INSERT INTO EventProject
VALUES
('event 1','cfc','cairo','1/1/2019','mark',1,1), ('event 2','guc','cairo','4/3/2019','carol',2,2)
SELECT * FROM EventProject



INSERT INTO Advertisement (descriptionAd,locationAd,event_id,viewer_id) 
VALUES 
('CFC AD','CFC',1,1),('GUC AD','GUC',2,2)

SELECT * FROM Advertisement

INSERT INTO Existing_Request (original_content_id,viewer_id) values (1,1) , (2,2)

SELECT * FROM Existing_Request


INSERT INTO New_Request  (accept_status,specified,information,viewer_id,notif_obj_id,contributor_id)
values
(1,1,'1st request',1,4,4),
(1,1,'2nd request',2,5,4),
(1,1,'3rd request',1,6,5),
(1,1,'4th request',2,7,5),
(1,1,'5th request',3,8,5)

INSERT INTO New_Request (accept_status,specified,viewer_id,notif_obj_id,contributor_id)
VALUES
(1,1,1,9,4),
(1,1,2,10,7),
(1,1,3,11,8)

INSERT INTO New_Request (accept_status,specified,information,viewer_id,notif_obj_id)
VALUES
(0,0,'9th request',1,12),
(0,0,'10th request',2,13),
(0,0,'11th request',3,3)







