USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_DEL_BANGDING]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[WX_DEL_BANGDING](@OPENID varchar(50),@C_HH varchar(50))
as
		delete from FH_WXOPENIDCHH where OPENID=@OPENID AND C_HH=@C_HH
GO
