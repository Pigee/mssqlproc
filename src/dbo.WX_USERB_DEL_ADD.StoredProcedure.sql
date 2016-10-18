USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_USERB_DEL_ADD]    Script Date: 10/18/2016 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[WX_USERB_DEL_ADD](@ID varchar(36), @OPENID varchar(50), @C_HH varchar(20), @UPDATE_DATE varchar(20))
as
		delete from FH_WXOPENIDCHH where OPENID = @OPENID AND C_HH = @C_HH;
		insert into FH_WXOPENIDCHH (ID,OPENID,C_HH,UPDATE_DATE) values (@ID,@OPENID,@C_HH,@UPDATE_DATE);
GO
