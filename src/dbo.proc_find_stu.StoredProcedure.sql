USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[proc_find_stu]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[proc_find_stu](@USERB_KH varchar(20), @C_YHM varchar(50))
as
		select * from FH_USERBASE WHERE USERB_KH = @USERB_KH and USERB_HM = @C_YHM and IS_ENABLED='1'
GO
