USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_GETYM]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FUNC_GETYM]
( 
  @PARA_Y INT,
  @PARA_M INT
)
RETURNS VARCHAR(20)
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  DECLARE @RESULT VARCHAR(20)
   SET @RESULT = CAST(@PARA_Y AS VARCHAR) + CASE WHEN @PARA_M <=9 THEN '0'+CAST(@PARA_M AS VARCHAR) ELSE CAST(@PARA_M AS VARCHAR) END;
  RETURN @RESULT
END
GO
