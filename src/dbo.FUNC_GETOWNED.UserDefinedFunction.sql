USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_GETOWNED]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FUNC_GETOWNED]
( 
   @paraUser varchar(20)
)
RETURNS varchar(20)-- nvarchar
AS
BEGIN
  DECLARE @USERB_KH VARCHAR(20)
  SET @USERB_KH = 'FSDFDF'
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  RETURN @USERB_KH
END
GO
