USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[sp_test]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_test](@USERB_KH VARCHAR(36), @DEBTL_YEAR INT OUTPUT)

AS
BEGIN

--select @userb_kh UB_KH;

update fh_bank set bank_id = '343434' where bank_no = '2434343434343';

SET @DEBTL_YEAR = 2323;
RETURN @DEBTL_YEAR ;






END
GO
