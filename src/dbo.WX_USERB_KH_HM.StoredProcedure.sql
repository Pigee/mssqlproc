USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_USERB_KH_HM]    Script Date: 10/18/2016 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[WX_USERB_KH_HM](@USERB_KH varchar(20), @USERB_HM varchar(50))
as
		select *,'QY' as DATA_FLAG from FH_USERBASE WHERE USERB_KH = @USERB_KH and USERB_HM = @USERB_HM and IS_ENABLED='1'
GO
