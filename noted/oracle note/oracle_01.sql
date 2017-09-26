SQL:
  Structured Query Language 结构化查询语言
SQL分类:4类
  DDL: 数据定义语言,主要定义是结构  create alter, drop,truncate     
  DML: 数据操纵语言,主要是操作数据  insert ,update , delete
  DCL: 数据控制语言,主要控制权限 grant  revoke
  DQL: 数据查询语言 , 查询数据  select 

SQL编写顺序/查询结构:
  select 显示的列 from 表名 where 条件 group by 分组条件 having 分组之后的过滤 order by 排序  
       

dual : 虚表/伪表 , 主要用于补齐语法结构的

select 1+1 from dual;
select * from dual;

如果包含特殊字符,需要加双引号
select ename as 姓名,job "工%作" from emp;

-- 计算员工的年薪 + 奖金
select emp.*,sal*12,sal*12+comm from emp;
-- nvl(参数1,参数2) ,如果参数1为null , 则返回参数2, 否则返回参数1
select nvl(null,2) from dual;  -- 2
select nvl(1,2) from dual; -- 1
select emp.*,sal*12,sal*12+nvl(comm,0) from emp;

/*
     字符串拼接:
       通用方式: 
         concat(str1,str2) : str1str2
        
       Oracle特有的方式:  
         ||  相当于是java中 +  
*/
-- 姓名:SMITH
select concat('姓名:',ename) from emp;

select '姓名'||ename from emp;
select '姓名'||ename||'sdfsdf' from emp;


/*
       条件查询 : where 后面的写法
            关系运算符: > >= = < <= != <> 
                        != : sqlserver
                        <> : sql标准
            逻辑运算符: and or not 
            其它运算符: 
                  in(集合)
                  like 模糊查询
                  between..and.. 区间 [最小值,最大值]
                  is null
                  is not null
                  exists 存在
*/
-- 查询每月能得到奖金的员工信息
select * from emp where comm != null; -- 错误的
select * from emp where comm is not null;

-- 查询工资在1500--3000之间的员工信息
select * from emp where sal between 1500 and 3000;
select * from emp where sal >=1500 and sal <=3000;

-- 查询名字在某个范围的员工信息 'ALLEN','BLAKE','CLARK'
select * from emp where ename in('ALLEN','BLAKE','CLARK');

-- Oracle数据区分大小写的(表中的数据区分大小写，列名不区分大小写)
select * from emp where ename = 'allen';


/*
    模糊查询:
        like 
             % 匹配的是任意字符
             _ 匹配单个字符
             
       escape 相当于是指定使用 哪个转义字符
*/
-- 查询名字中第三个字母是A的员工信息
select * from emp where ename like '__A%';

-- 查询名称中包含%的员工信息
insert into emp(empno,ename) values(9527,'HUA%AN');
select * from emp where ename like '%\%%' escape '\';


/*
       order by 列名 排序规则
             asc : ascend  默认规则 升序
             desc: descend 降序
       排序时的空值问题 :     
             nulls first(把含有空值的行置顶) | nulls last(把含有空值的行置底)  
             
       多列排序
             order by 列名1 规则, 列名2 规则    
*/
-- 升序排序
select * from emp order by sal asc;
-- 按照工资进行降序排序
select * from emp order by sal desc nulls last;

-- 按照部门deptno降序排序,再按照工资sal进行升序排序
select * from emp order by deptno desc,sal asc; 

/*
       函数:
          单行函数:
              数值函数
              字符函数
              日期函数
              转换函数
              通用函数
          多行函数:
               sum() max , min ,count ,avg
*/
-- 数值函数:
-- 四舍五入   Math
select round(45.926,2) from dual; -- 45.93
select round(45.926,1) from dual; -- 45.9
select round(45.926,0) from dual; -- 46
select round(45.926,-1) from dual; -- 50
select round(45.926,-2) from dual; --0 

-- 截断
select trunc(45.926,2) from dual; -- 45.92
select trunc(45.926,1) from dual; -- 45.9
select trunc(45.926,0) from dual; -- 45
select trunc(45.926,-1) from dual; -- 40
select trunc(45.926,-2) from dual; --0 

-- 向上取整 : 向大值取值
select ceil(12.5) from dual; -- 13
select ceil(-12.5) from dual; -- -12 
-- 向下取整 : 向小值取整
select floor(10.9) from dual; -- 10
select floor(-10.9) from dual; -- 11;

-- 模运算: 取余数 
select mod(9,2) from dual; -- 1;

-- 绝对值
select abs(-10) from dual; -- 10;

-- 字符串函数
-- 取长度
select length('abcdefg') from dual;

-- 去除两端空格
select ' hello              ' from dual;
select trim(' hello              ') from dual;

-- 字符串截取
-- 不管起始索引是0还是1 , 都是从第1个字符开始截取, 
select substr('abcdefg',0,3) from dual; -- abc
select substr('abcdefg',1,3) from dual; -- abc
select substr('abcdefg',2,3) from dual; -- bcd

-- 字符串替换
select replace('hello','l','x') from dual;


-- 日期函数
-- 当前日期
select sysdate from dual; -- 2017/9/5 11:59:25

select sysdate+1/24 from dual;

-- 计算员工入职的天数
select ceil(sysdate - hiredate) from emp;

-- 计算员工入职的周数
select ceil(sysdate - hiredate)/7 from emp;

-- 计算员工入职的月数
select months_between(sysdate,hiredate) from emp;

-- 计算员工入职的年数
select months_between(sysdate,hiredate)/12 from emp;

-- 几个月之后的今天
select add_months(sysdate,3) from dual;



/*
       转换函数:
              字符转数值 : to_number  鸡肋
              数值转字符 : to_char
              日期转字符: to_char
              字符转日期 : to_date
*/
select 100 + '23' from dual; -- 123
select 100 + to_number('23') from dual; -- 123

-- 数值转字符: 100   $100  1,234,567
select to_char(1234567,'$9,999,999.99') from dual;

-- 日期转字符  mi  minute
select to_char(sysdate,'yyyy-mm-dd hh:mi:ss') from dual;

-- 只显示年份
select to_char(sysdate,'yyyy') from dual; 

select to_char(sysdate,'d') from dual;  -- 一个星期过了几天 3
select to_char(sysdate,'dd') from dual;  -- 一个月中的天数
select to_char(sysdate,'ddd') from dual; -- 一年过了几天 248


select to_char(sysdate,'day') from dual;  -- tuesday  星期二 
select to_char(sysdate,'dy') from dual;  -- tue 星期的简写
select sysdate from dual;


-- 字符转日期
-- 查询1980-01-01-1985-12-31日入职的员工信息
select * from emp where hiredate between to_date('1980-01-01','yyyy-mm-dd') and to_date('1985-12-31','yyyy-mm-dd');

select to_date('1980-01-01','yyyy-mm-dd') from dual;


-- 通用函数
-- nvl2
select nvl2(null,5,6) from dual; -- 6 
select nvl2(1,5,6) from dual; -- 5

-- 条件表达式
/*
  通用的方式: 
     case 列名
       when 值1 then 处理
       when 值2 then 处理
       else
         
       end;
  Oracle特有方式:
     decode(列名,if1,then1,if2,then2,else)       
  
*/
-- 员工取一个中文名
select emp.ename,case ename
          when 'SMITH' then '史密斯'
          when 'ALLEN' then '诸葛村夫'
          else
               '路人甲'
          end
 from emp;
 
select decode(ename,'SMITH','刘备小儿','JONES','曹贼','宝宝') from emp;
 
/*
     分组查询:                                            
           group by 
     分组查询语句结构?
           select 分组的条件,分组之后的操作 from 表名 group by 分组条件 having 条件过滤

          where 和 having 区别?
                where 是分组之前执行  不能接聚合函数
                having 分组之后执行   可以接聚合函数 
*/
-- 查询平均工资大于2000的部门
select deptno,avg(sal) from emp group by deptno having avg(sal) > 2000;


delete from emp where empno=9527;
select * from emp order by deptno;



-- 17,统计 薪资 大于 薪资最高的员工 所在部门 的平均工资 和 薪资最低的员工 所在部门 的平均工资 的平均工资 的员工信息。
----       sal   >                    10         100    and                20         200       100+200/2
-- select * from emp where sal > (100+200)/2

课后作业：

(1)选择姓名中有字母a和e的员工姓名
[instr(ename, 'A')：在一个字符串中查找指定的字符,返回被查找到的指定的字符的位置，大于0说明存在]
[substr('abcdefg',1,3)：用于截取并返回截取的字符串，中间填写0和1均表示从第一个字母开始]
	select ename from emp where instr(ename, 'A')>0 and instr(ename, 'E')>0;
		或者
	select last_name from employees where last_name like '%a%' and last_name like '%e%'

