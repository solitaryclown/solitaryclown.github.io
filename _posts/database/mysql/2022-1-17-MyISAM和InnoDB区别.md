---
layout: post
date: 2022-01-17 21:21:06 +0800
author: solitaryclown
title: MyISAM和InnoDB区别
categories: database
tags: mysql
# permalink: /:categories/:title.html
excerpt: "MySQL的存储引擎中常用的两个：MyISAM和InnoDB，它们有什么差异？"
---
* content
{:toc}


# MyISAM和InnoDB

## 数据存储结构
首先，最重要的一点区别是它们的数据存储结构不同：  
MyISAM索引文件和数据文件是分开存储的，而InnoDB索引文件中就存储了真实的数据，即：在InnoDB中，数据文件就是索引文件本身。

在InnoDB存储引擎中，每个表都必须有主键以支持索引文件的构建。
1. 如果没有显式指明PRIMARY KEY，系统会用第一个UNIQUE且NOT NULL的字段作为主键。
2. 如果没有显式指明主键且没有唯一且非空的字段，系统会用一个48bit的ROW-ID作为主键。

在InnoDB存储引擎中：  
每个表都有一个聚簇索引，以主键作为索引字段，所有的数据就存在这个索引树的叶子节点中，每个叶子结点存储一行数据。  
对于其他非主键索引字段，索引称为辅助索引，这种索引树的叶子节点存储的是：以该字段的值作为key，以key对应的主键值作为value，因此，当查询以辅助索引字段作为条件时，是先查到对应的主键值，再根据主键值去聚簇索引树中查询真实数据。


两个系统的详细区别如下表：

| BASIS FOR COMPARISON                  | InnoDB                                                                                                                                                        | MyISAM                                                                                                                                  |
| :------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------- |
| Type Of MySQL Version Stored          | InnoDB is the default storage engine for MySQL 5.5 and higher.                                                                                                | MyISAM is the default storage engine for MySQL 5.4 and lower.                                                                           |
| Table-Locking Vs Row-Locking          | InnoDB supports row-level locking.                                                                                                                            | MyISAM supports table-level locking.                                                                                                    |
| Storage Of Tables, Data And Indexes   | InnoDB stores its tables and indexes in tablespace.                                                                                                           | MyISAM stores tables, data and indexes in diskspace using separate three different files. (tablename.FRM, tablename.MYD, tablename.MYI) |
| Referential Integrity And Foreign Key | InnoDB is a relational DBMS (RDBMS) and therefore it has Referential Integrity and supports Foreign Key, including cascade deletes and updates.               | MyISAM is not an RDBMS and hence does not support Referential Integrity and Foreign Key.                                                |
| Speed                                 | InnoDB is faster for writes.                                                                                                                                  | MyISAM is faster for reads.                                                                                                             |
| Caching                               | InnoDB supports large buffer pool for both data and indexes.                                                                                                  | MyISAM key buffer is only for indexes.                                                                                                  |
| Full Text Indexing                    | In InnoDB there is No Full Text Search.                                                                                                                       | Full Text Search is supported in MyISAM.                                                                                                |
| Acid Properties                       | InnoDB supports ACID (Atomicity, Consistency, Isolation and Durability) properties.                                                                           | MyISAM does not support ACID (Atomicity, Consistency, Isolation and Durability) properties.                                             |
| Transactions                          | InnoDB supports Transactions (Rollback, Commit).                                                                                                              | MyISAM does not support Transactions.                                                                                                   |
| Nature                                | With the roll out of version 8.0, it’s clear that, all future enhancements will be on InnoDB.                                                                 | MyISAM is not dynamic in nature.                                                                                                        |
| Performance                           | InnoDB’s performance for high volume data is by far better than that of MyISAM.                                                                               | MyISAM performance for high volume data is poor than that of InnoDB.                                                                    |
| Reliability                           | InnoDB gives reliability as it uses a transactional log to maintain such operations and hence, in case of failure, it can recover easily by using those logs. | MyISAM offers no data integrity; hardware failures and canceled operations can cause data to become corrupt.                            |