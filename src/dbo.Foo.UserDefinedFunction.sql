USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[Foo]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Foo]() 
RETURNS int 
AS 
BEGIN 
declare @n int 
select @n=3 
return @n 
END
GO
