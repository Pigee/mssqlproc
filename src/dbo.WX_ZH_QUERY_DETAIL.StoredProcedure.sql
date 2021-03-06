USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_ZH_QUERY_DETAIL]    Script Date: 10/18/2016 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：微信根据用户卡号查找用户信息
  说明：
**/
CREATE  PROCEDURE [dbo].[WX_ZH_QUERY_DETAIL](@USERB_KH VARCHAR(100))
AS
BEGIN
		SELECT 
    T.USERB_HM,
    T.USERB_KH,
     T.USERB_DH,
     T.USERB_ADDR,
     T2.CX_YE,
     TY.WATERT_NAME
    FROM 
    FH_USERBASE T LEFT JOIN FH_CX T2 ON T.USERB_KH=T2.USERB_KH,
    FH_WATERTYPE TY
    WHERE 
    T.USERB_YHLX=TY.WATERT_NO
    AND
    T.USERB_KH=@USERB_KH
END
GO
