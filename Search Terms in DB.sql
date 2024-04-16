USE [Database_Name];
GO

DECLARE @SearchTerm1 NVARCHAR(100) = N'The name or value of the first search term',
        @SearchTerm2 NVARCHAR(100) = N'The name or value of the second search term';

DECLARE @TableName NVARCHAR(100);
DECLARE @ColumnName NVARCHAR(100);

DECLARE table_cursor CURSOR FOR
  SELECT t.TABLE_NAME, c.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLES t
   INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_NAME = t.TABLE_NAME
   WHERE t.TABLE_TYPE = 'BASE TABLE'
     AND c.DATA_TYPE LIKE '%VARCHAR%'
     AND t.TABLE_NAME LIKE 'tbl%'
     AND c.COLUMN_NAME LIKE '%col%';

OPEN table_cursor;
FETCH NEXT FROM table_cursor
 INTO @TableName, @ColumnName;

WHILE @@fetch_status = 0
  BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql
      = N'IF EXISTS (   SELECT 1 FROM ' + @TableName + N' WHERE ' + @ColumnName + N' LIKE ''%' + @SearchTerm1
        + N'%'' /*OR ' + @ColumnName + N' LIKE ''%' + @SearchTerm2 + N'%''*/) PRINT ''' + @TableName
        + N''' + '' - '' + ''' + @ColumnName + N''';';
    EXEC sp_executesql @sql;

    FETCH NEXT FROM table_cursor
     INTO @TableName, @ColumnName;
  END;

CLOSE table_cursor;
DEALLOCATE table_cursor;
