USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_NO_PAY]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WX_NO_PAY]
(@USERB_KH varchar(50))
AS
BEGIN
  select CONVERT(varchar(100), t.CREATE_DATE, 20)	CREATE_DATE
	from FH_WEIXINDEAL t where t.CUST_KH=@USERB_KH and t.DEAL_DATE is NULL 
	ORDER BY t.CREATE_DATE DESC
END
GO
