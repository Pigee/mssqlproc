USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_USERB_KH]    Script Date: 10/18/2016 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[WX_USERB_KH](@USERB_KH varchar(50))
as
		select *,(SELECT WATERT_NAME FROM FH_WATERTYPE WHERE WATERT_NO = a.USERB_YSXZ) USERB_YSXZ1 from FH_USERBASE a WHERE USERB_KH = @USERB_KH
GO
