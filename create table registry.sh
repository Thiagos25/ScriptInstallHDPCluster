
CREATE USER 'registry'@'thiago-5.field.hortonworks.com' IDENTIFIED BY 'qweqwe123';
GRANT ALL PRIVILEGES ON * . * TO 'registry'@'thiago-5.field.hortonworks.com';
FLUSH PRIVILEGES;
CREATE DATABASE registry;


CREATE USER 'streamline'@'thiago-5.field.hortonworks.com' IDENTIFIED BY 'qweqwe123';
GRANT ALL PRIVILEGES ON * . * TO 'streamline'@'thiago-5.field.hortonworks.com';
FLUSH PRIVILEGES;
CREATE DATABASE streamline;




CREATE USER 'registry'@'localhost' IDENTIFIED BY 'qweqwe123';
GRANT ALL PRIVILEGES ON * . * TO 'registry'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE registry;


CREATE USER 'streamline'@'localhost' IDENTIFIED BY 'qweqwe123';
GRANT ALL PRIVILEGES ON * . * TO 'streamline'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE streamline;


CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'rangerdba';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';

CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'rangerdba';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;


create user 'root'@'bacen-3.field.hortonworks.com' identified by 'qweqwe123'; 
grant all privileges on *.* to 'root'@'bacen-3.field.hortonworks.com'; 
flush privileges;

create user 'root'@'localhost' identified by 'qweqwe123'; 
grant all privileges on *.* to 'root'@'localhost'; 
flush privileges;
 





  
  