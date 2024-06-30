-- 以下操作都是基于某个具体的容器数据库的操作
----------------------------------------创建行为------------------------------------------------------
-- 创建表空间
 CREATE TABLESPACE "BUSDATA"                        --表空间名 BUSDATA
    LOGGING                                     --启动重做日志
    DATAFILE 'E:\oracle\19c\oradata\ORCL\orclpdb\BUSDATA.DBF'     --指定对应的数据文件，可以一个或者多个
    SIZE 512M                                   --数据文件大小
    AUTOEXTEND ON                               --数据文件自动扩展
    NEXT 1024K                                  --一次扩展的大小
    MAXSIZE UNLIMITED                           --数据文件最大容量：无限
    EXTENT MANAGEMENT LOCAL                     --表空间本地管理
    SEGMENT SPACE MANAGEMENT AUTO;


-- 创建用户
CREATE USER "BUSUSER"         --创建用户 BUSUSER
PROFILE "DEFAULT"            --忽略对profile中的一些资源限制
IDENTIFIED BY "654321"       --密码为weixin
DEFAULT TABLESPACE "BUSDATA"  --默认表空间WEIXIN，即数据默认存此表空间
ACCOUNT UNLOCK; 

-- 创建表
CREATE TABLE employees (
  employee_id NUMBER(10) PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name VARCHAR2(50) NOT NULL,
  birth_date DATE,
  hire_date DATE DEFAULT SYSDATE,
  department_id NUMBER(10),
  salary NUMBER(8, 2),
  CONSTRAINT chk_salary CHECK (salary > 0)  -- 约束salary大于0
); 

-- 创建序列
CREATE SEQUENCE BUS_SEQUENCE  -- 序列的名称 BUS_SEQUENCE
INCREMENT BY 1                -- 每次调用序列时增加的数值
START WITH 100000                  -- 序列开始的数值，默认是1
MAXVALUE 9999999999           -- 序列可以生成的最大数值
MINVALUE 1               -- 序列可以生成的最小数值
NOCYCLE       -- 如果序列达到MAXVALUE或MINVALUE，它将根据设置重置到START WITH或MINVALUE的值。NOCYCLE表示序列不会重置。
CACHE 20       -- 允许Oracle缓存一定数量的序列值以提高性能
ORDER;         -- 保证序列值的生成顺序

----------------------------------------变更行为------------------------------------------------------
-- 开启容器
alter pluggable database pdb名称 open;
-- 切换容器
alter session set container=ORCLPDB;
-- 修改用户密码
alter user XYY identified by 654321;

----------------------------------------查询行为------------------------------------------------------
-- 查看当前会话的容器名称
select con_id, name, open_mode from v$pdbs;
-- 查询表空间
select * from dba_data_files where tablespace_name='BUSDATA';
-- 查询用户
SELECT * FROM dba_users where USERNAME = '用户名称';
-- 查询角色
SELECT * FROM dba_roles;
-- 查询用户拥有的表权限，注意区分大小写
SELECT * FROM USER_TAB_PRIVS WHERE GRANTEE = 'SYSTEM';
-- 查询用户拥有的角色
SELECT * FROM dba_role_privs WHERE grantee = 'SYS';

-- 查询 V$PWFILE_USERS 视图：这个视图列出了具有 sysdba 和 sysoper 权限的用户
SELECT * FROM V$PWFILE_USERS WHERE SYSDBA = 'TRUE';

-- 查询 DBA_SYS_PRIVS 视图：这个数据字典视图显示了哪些用户或角色被直接授予了系统权限
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'YOUR_USERNAME' AND PRIVILEGE = 'SYSDBA';

----------------------------------------赋权行为------------------------------------------------------
-- 给BUSUSER用户赋予dba角色，connect，resource权限，注意名字有特殊字符时名字要加双引号
-- with admin option 表示在获得权限的同时也获得了将这个权限授予其他用户的能力。
GRANT "DBA",connect,resource TO "BUSUSER";
GRANT "DBA",connect, resource TO "BUSUSER" WITH ADMIN OPTION; 

-- 给用户bus赋予sysdba权限，用户可以以sysdba角色连接数据库
-- 注意：赋予dba权限意味着用户拥有和sysdba一样的权限，并不是sysdba
GRANT sysdba TO bus;

-- 将my_table的SELECT,UPDATE, DELETE 权限赋予给my_user用户
GRANT SELECT,UPDATE, DELETE ON my_table TO 'my_user';
-- 授予reporting_user用户对所有表的 SELECT 权限：
GRANT SELECT ON ALL TABLES TO 'reporting_user';

-- 将my_sequence使用权限赋予给my_user用户
GRANT USAGE ON my_sequence TO my_user;
-- 授予 SELECT 权限
GRANT SELECT ON my_sequence TO my_user;
-- 获取序列写一个值
my_sequenc.nextval
-- 获取序列当前值
my_sequenc.CURRVAL

----------------------------------------删除行为------------------------------------------------------
-- 删除表空间
-- 删除表空间之前，需要将其设置为离线状态
ALTER TABLESPACE your_tablespace_name OFFLINE;
-- 如果表空间为空，可以直接删除
DROP TABLESPACE your_tablespace_name;
-- 如果表空间不为空，需要使用 INCLUDING CONTENTS 选项来删除表空间及其内容
DROP TABLESPACE your_tablespace_name INCLUDING CONTENTS;
-- 如果需要同时删除数据文件，可以使用 AND DATAFILES 选项
DROP TABLESPACE your_tablespace_name INCLUDING CONTENTS AND DATAFILES;

---------------------------------------附加行为------------------------------------------------------
-- oracle的安全策略方面默认一个用户的密码有效期为180天，我们可以直接把这个有效期调成永久。
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
