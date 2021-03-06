USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_FEE_DETAIL]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：根据账单id查询所有收费项明细
  说明：
  author： junlong&QY.lin
**/
CREATE PROCEDURE [dbo].[SP_FEE_DETAIL](@DEBTL_ID VARCHAR(36))
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	DECLARE @ALL_FEE_TYPE NVARCHAR(MAX),
					@STATEMENT NVARCHAR(MAX);
	
	--取费用类型
	SELECT @ALL_FEE_TYPE = LEFT( COSTI_NO, LEN(COSTI_NO)-1)
	FROM(
				SELECT   TYPE,
								 COSTI_NO = 
								 (
										 SELECT   '"' + COSTI_NO + '"' + ','  
										 FROM   ( SELECT  1 TYPE,  COSTI_NO FROM FH_COSTITEM ) AS b  
										 WHERE  b.TYPE = d.TYPE FOR XML PATH('')  
								 )
								   
				FROM   (SELECT 1 TYPE,  COSTI_NO from FH_COSTITEM ) AS d  
				GROUP BY TYPE 
	) c ; 

	SET @STATEMENT = 
	'
		select * 
		from (
					select 	payl_total, DEBTL_ID, payl_no 
					from 		FH_PAYLIST 
					where DEBTL_ID =  @DEBTL_ID 
		) t 
		PIVOT(SUM(payl_total) for payl_no in (' + @ALL_FEE_TYPE + ' )
		) A
	';
	
	EXEC SP_EXECUTESQL @STATEMENT, 
	N'@DEBTL_ID VARCHAR(36)', --, @ALL_FEE_TYPE VARCHAR(36)
	@DEBTL_ID; --, @ALL_FEE_TYPE
	

END
GO
