USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_GETNO]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FUNC_GETNO]
( 
)
RETURNS float
AS
BEGIN
  return 45+23
END
GO
