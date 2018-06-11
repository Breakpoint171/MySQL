# 创建数据库
create database school default charset utf8 collate utf8_general_ci;

use school;
# 创建表
drop table if exists class;
create table class (
cid int(11) not null auto_increment primary key,
caption varchar(30) not null
)engine=innodb default char set=utf8;

drop table if exists student;
create table student(
sid int(11) not null auto_increment primary key,
sname varchar(30) not null,
gender char(1) not null,
class_id int(11) not null,
constraint fk_class foreign key (class_id) references class(cid)
)engine=innodb default char set=utf8;

drop table if exists teacher;
create table teacher(
tid int(11) not null auto_increment primary key,
tname varchar(30) not null
)engine=innodb default char set=utf8;

drop table if exists course;
create table course(
cid int(11) not null auto_increment primary key,
cname varchar(30) not null,
teacher_id int(11) not null,
constraint fk_teacher foreign key (teacher_id) references teacher(tid)
)engine=innodb default char set=utf8;

drop table if exists score;
create table score(
sid int(11) not null auto_increment primary key,
student_id int(11) not null,
course_id int(11) not null,
num int(11) not null,
constraint fk_student foreign key (student_id) references student(sid),
constraint fk_course foreign key (course_id) references course(cid)
)engine=innodb default char set=utf8;

# 向表中插入数据

insert into class(caption) values ('三年二班'),('三年三班'),('一年二班'),('二年九班');

insert into course(cname,teacher_id) values ('生物', 1), ( '物理', 2), ('体育', 3), ('美术', 2);

insert into student(gender,class_id,sname) values ('男', '1', '理解'), ('女', '1', '钢蛋'), ('男', '1', '张三'), 
('男', '1', '张一'), ('女', '1', '张二'), ('男', '1', '张四'), ('女', '2', '铁锤'),
 ('男', '2', '李三'), ('男', '2', '李一'), ('女', '2', '李二'), ('男', '2', '李四'), 
 ('女', '3', '如花'), ('男', '3', '刘三'), ('男', '3', '刘一'), ('女', '3', '刘二'), 
 ('男', '3', '刘四');

insert into teacher(tname) values ('张磊老师'), ('李平老师'), ('刘海燕老师'),
 ('朱云海老师'), ('李杰老师');


insert into score(student_id,course_id,num) values ('1', '1', '10'), ('1', '2', '9'), ('1', '4', '66'), ( '2', '1', '8'),
 ('2', '3', '68'), ('2', '4', '99'), ('3', '1', '77'), ('3', '2', '66'), ('3', '3', '87'),
 ('3', '4', '99'), ('4', '1', '79'), ('4', '2', '11'), ('4', '3', '67'), ('4', '4', '100'),
 ('5', '1', '79'), ('5', '2', '11'), ('5', '3', '67'), ('5', '4', '100'), ('6', '1', '9'),
 ( '6', '2', '100'), ('6', '3', '67'), ('6', '4', '100'), ('7', '1', '9'), ('7', '2', '100'), 
 ('7', '3', '67'), ('7', '4', '88'), ('8', '1', '9'), ('8', '2', '100'), ('8', '3', '67'), 
 ('8', '4', '88'), ('9', '1', '91'), ('9', '2', '88'), ('9', '3', '67'), ('9', '4', '22'),
 ('10', '1', '90'), ('10', '2', '77'), ('10', '3', '43'), ('10', '4', '87'), ('11', '1', '90'),
 ('11', '2', '77'), ('11', '3', '43'), ('11', '4', '87'), ('12', '1', '90'), ('12', '2', '77'), 
 ('12', '3', '43'), ('12', '4', '87'), ('13', '3', '87');
 
 
 # 查询“生物”课程比“物理”课程成绩高的所有学生的学号；
 select A.student_id,sw,wl from
(select student_id, num as sw from score left join course on score.course_id=course.cid where course.cname='生物') as A
left join
(select student_id, num as wl from score left join course on score.course_id=course.cid where course.cname='物理') as B
on A.student_id = B.student_id where if(isnull(sw),0,sw) > if(isnull(wl),0,wl);

# 查询平均成绩大于60分的同学的学号和平均成绩；
select student_id,avg(num) from score group by student_id having avg(num) > 60;

# 查询所有同学的学号、姓名、选课数、总成绩；
select student.sid,student.sname,count(course_id),sum(num) from student left join score on student.sid=score.student_id group by student_id;

# 查询姓“李”的老师的个数；

select count(1) from teacher where tname like '李%';

# 查询没学过“李平”老师课的同学的学号、姓名；
select distinct student.sid,student.sname from student where sid not in 
(select distinct student_id from score where course_id in
(select course.cid from teacher left join course on teacher.tid = course.teacher_id where teacher.tname='李平老师'));

# 查询学过“001”并且也学过编号“002”课程的同学的学号、姓名；
select student_id,sname from student left join
(select student_id,course_id from score where course_id=1 or course_id=2) as B
on sid = B.student_id group by student_id having count(course_id) > 1;

# 查询学过“李平”老师所教的所有课的同学的学号、姓名；
select student.sid,student.sname from student where student.sid in 
(select distinct student_id from score where course_id in
(select course.cid from course left join teacher on course.teacher_id = teacher.tid where tname = '李平老师'));

# 查询课程编号“002”的成绩比课程编号“001”课程低的所有同学的学号、姓名
select sid,sname,num1,num2 from student left join
(select student_id, num as num1 from score where course_id = 001) as A
on student.sid = A.student_id
left join
(select student_id, num as num2 from score where course_id = 002) as B
on A.student_id = B.student_id group by A.student_id having if(isnull(num1),0,num1) > if(isnull(num2),0,num2);

# 查询有课程成绩小于60分的同学的学号、姓名；
select distinct student.sid,student.sname from student left join score on student.sid = score.student_id where num < 60;

# 查询没有学全所有课的同学的学号、姓名；
select student.sid,student.sname from student left join score on student.sid = score.student_id group by student_id having count(course_id) < (select count(1) from course);

# 查询至少有一门课与学号为“001”的同学所学相同的同学的学号和姓名；
select student.sid,student.sname from student left join score on student.sid = score.student_id where course_id in 
(select course_id from score left join student on student.sid = score.student_id where score.student_id = 1) group by student_id;

# 查询至少学过学号为“001”同学所有课的其他同学学号和姓名
select student.sid,sname 
from student left join score on score.student_id = student.sid 
where course_id in 
(select course_id from score where student_id = 1)
group by student_id having count(course_id) = (select count(course_id) from score where student_id = 1);

# 查询和“002”号的同学学习的课程完全相同的其他同学学号和姓名；
select student_id,sname from score left join student on score.student_id = student.sid where student_id in (
select student_id from score  where student_id != 2 
group by student_id HAVING count(course_id) = (select count(1) from score where student_id = 2)
) and course_id in (select course_id from score where student_id = 2) 
group by student_id HAVING count(course_id) = (select count(2) from score where student_id = 2);

# 删除学习“李平”老师课的score表记录
delete from score where course_id in (
select course.cid from course left join teacher on teacher.tid = course.teacher_id where tname = '李平老师'
);

# 向SC表中插入一些记录，这些记录要求符合以下条件：①没有上过编号“002”课程的同学学号；②插入“002”号课程的平均成绩
insert into score(student_id,course_id,num) (select sid,2, (select avg(num) from score where course_id = 2) from student 
where sid not in (select student_id from score where course_id= 2));

# 按平均成绩从低到高 显示所有学生的“生物”、“物理”、“体育”三门的课程成绩，按如下形式显示： 学生ID,语文,数学,英语,有效课程数,有效平均分；
select sc.student_id,
(select num from score left join course on score.course_id = course.cid where course.cname = '生物' and sc.student_id = score.student_id) as '生物',
(select num from score left join course on score.course_id = course.cid where course.cname = '物理' and sc.student_id = score.student_id) as '物理',
(select num from score left join course on score.course_id = course.cid where course.cname = '体育' and sc.student_id = score.student_id) as '体育',
count(sc.course_id),
avg(sc.num)
from score as sc
group by student_id order by avg(sc.num) desc;

# 查询各科成绩最高和最低的分：以如下形式显示：课程ID，最高分，最低分；
select course_id,max(num),min(num) from score group by course_id;

# 按各科成绩从低到高和及格率的百分数从高到低排序
select course_id, avg(num) as avgnum,sum(case when score.num > 60 then 1 else 0 END)/count(1)*100 as percent 
from score group by course_id order by avgnum asc,percent desc;

# 课程平均分从高到低显示（现实任课老师）
select avg(if(isnull(score.num),0,score.num)),teacher.tname from course
left join score on score.course_id = course.cid
left join teacher on course.teacher_id = teacher.tid
group by score.course_id;

# 查询各科成绩前三名的记录:(不考虑成绩并列情况)
select score.sid,score.course_id,score.num,T.first_num,T.second_num from score left join
(
select
sid,
(select num from score as s2 where s2.course_id = s1.course_id order by num desc limit 0,1) as first_num,
(select num from score as s2 where s2.course_id = s1.course_id order by num desc limit 3,1) as second_num
from
score as s1
) as T
on score.sid =T.sid
where score.num <= T.first_num and score.num >= T.second_num;

# 查询每门课程被选修的学生数
select count(1) from score group by course_id;

# 查询出只选修了一门课程的全部学生的学号和姓名；
select student.sid,student.sname from student left join score on student.sid = score.student_id group by student_id having count(course_id) = 1;

# 查询男生、女生的人数
select count(1),gender from student group by gender;

# 查询姓“张”的学生名单
select sname from student where sname like '张%';

# 查询同名同姓学生名单，并统计同名人数
select count(1),sname from student group by sname;

# 查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列
select course_id,avg(num) from score group by course_id order by avg(num),course_id desc;

# 查询平均成绩大于85的所有学生的学号、姓名和平均成绩
select student_id,sname,avg(num) from score left join student on student_id = student.sid group by student_id having avg(num)>85;

# 查询课程名称为“数学”，且分数低于60的学生姓名和分数；
select sname,num from score left join course on score.course_id = course.cid
left join student on student.sid = score.student_id where course.cname = '生物'
and num < 60;

# 查询课程编号为003且课程成绩在80分以上的学生的学号和姓名
select student.sid,sname,num,course_id from student left join score on student.sid = score.student_id where course_id = 3 and num > 80;

# 求选了课程的学生人数
select count(distinct student_id) from score;

# 查询选修“张磊”老师所授课程的学生中，成绩最高的学生姓名及其成绩
select sname,num from score
left join student on score.student_id = student.sid
where score.course_id in (select course.cid from course left join teacher on course.teacher_id = teacher.tid where tname='张磊老师')
order by num desc limit 1;

# 查询各个课程及相应的选修人数
select course_id,count(1) from score group by course_id;

# 查询不同课程但成绩相同的学生的学号、课程号、学生成绩
select DISTINCT s1.course_id,s2.course_id,s1.num,s2.num from score as s1, score as s2 where s1.num = s2.num and s1.course_id != s2.course_id;

# 查询每门课程成绩最好的前两名
select score.sid,score.course_id,score.num,T.first_num,T.second_num from score left join
(
select
sid,
(select num from score as s2 where s2.course_id = s1.course_id order by num desc limit 0,1) as first_num,
(select num from score as s2 where s2.course_id = s1.course_id order by num desc limit 1,1) as second_num
from
score as s1
) as T
on score.sid =T.sid
where score.num <= T.first_num and score.num >= T.second_num;

# 检索至少选修两门课程的学生学号
select student_id from score group by student_id having count(student_id) > 1;

# 查询全部学生都选修的课程的课程号和课程名
select course_id,cname from score left join course on course.cid = score.course_id group by course_id having count(course_id)=(select count(1) from student);

# 查询没学过“李平”老师讲授的任一门课程的学生姓名
select student_id,student.sname from score
left join student on score.student_id = student.sid
where score.course_id not in (
select cid from course left join teacher on course.teacher_id = teacher.tid where tname = '张磊老师'
) group by student_id;

# 查询两门以上不及格课程的同学的学号及其平均成绩
select student_id,count(1) from score where num < 60 group by student_id having count(1) > 2;


# 检索“004”课程分数小于60，按分数降序排列的同学学号
select student_id from score where num < 60 and course_id = 4 order by num desc;

# 删除“002”同学的“001”课程的成绩
delete from score where course_id = 1 and student_id = 2;




































