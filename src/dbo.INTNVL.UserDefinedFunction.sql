USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[INTNVL]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[INTNVL]
( 
@PARA INT
)
RETURNS int -- nvarchar
AS
BEGIN
DECLARE @RESULT INT
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
IF @PARA IS NULL 
  SET  @RESULT = 0
ELSE 
  SET @RESULT = @PARA

RETURN @RESULT
END
GO
