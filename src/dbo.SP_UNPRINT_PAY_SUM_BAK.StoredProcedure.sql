USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_UNPRINT_PAY_SUM_BAK]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UNPRINT_PAY_SUM_BAK](@PAY_WAY VARCHAR(36))
AS
BEGIN
	DECLARE 	@ALL_FEE_TYPE VARCHAR(MAX),
						@PAY_WAY_TYPE_NAME VARCHAR(36),
						@PAY_TAG VARCHAR(36),
						@STATEMENT NVARCHAR(MAX);

	SET @PAY_WAY_TYPE_NAME = 'fh_xzfs';
	SET @PAY_TAG = '2';

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
----------------------------------------------------------------------------
	--取销帐类型
	IF @PAY_WAY IS NULL
			SELECT @PAY_WAY = LEFT( DATADIC_VALUE, LEN(DATADIC_VALUE)-1)
			FROM(
						SELECT 
											DATADIC_VALUE = 
											(
													SELECT  '''' + DATADIC_VALUE +''','
													FROM FH_DATADIC B
													WHERE A.DATADIC_TYPE = B.DATADIC_TYPE AND B.DATADIC_TYPE = @PAY_WAY_TYPE_NAME  
													FOR XML PATH('')  
										  )
							FROM  	FH_DATADIC A
							WHERE 	A.DATADIC_TYPE = @PAY_WAY_TYPE_NAME
							GROUP BY DATADIC_TYPE
			) c ; 
	ELSE 
	SET @PAY_WAY = '''' + @PAY_WAY + '''';
--------------------------------------------------------------------------------
	SET @STATEMENT = 
  '
			SELECT		*
			FROM			
			(
					SELECT 		PAYL_TOTAL, PAYL_NO
					FROM			FH_PAYLIST
					WHERE			DEBTL_ID IN
										(
												SELECT 	DEBTLIST_ID
												FROM
												(
														SELECT 	DEBTLIST_ID,
																		USERB_KH, 
																		DEBTL_YEAR, 
																		DEBTL_MON
														FROM 		FH_DEBTLIST
														WHERE		PAY_WAY IN (' + @PAY_WAY +') AND PAY_TAG = ''' + @PAY_TAG + '''
														UNION ALL 
														SELECT 	DEBTLIST_ID,
																		USERB_KH, 
																		DEBTL_YEAR, 
																		DEBTL_MON
														FROM 		FH_DEBTOWNHIS
														WHERE		PAY_WAY IN (' + @PAY_WAY +') AND PAY_TAG = ''' + @PAY_TAG + '''
												) A
												LEFT JOIN 	FH_BILLPRINT B
															ON 		A.DEBTL_YEAR != B.BILLP_YEAR AND A.DEBTL_MON != B.BILLP_MONTH AND A.USERB_KH != B.USERB_KH
										) 
			) T
			PIVOT(	SUM(PAYL_TOTAL) FOR PAYL_NO IN (' + @ALL_FEE_TYPE + ') ) A

			LEFT JOIN
			(
					SELECT		SUM(WATERP_QAN) WATERP_QAN, 
										SUM(DEBTL_ZNJ) DEBTL_ZNJ,
										SUM(DEBTL_ATOTAL) -  SUM(DEBTL_ZNJ) YSJE, 
										SUM(DEBTL_ATOTAL) DEBTL_ATOTAL
					FROM
					(
							SELECT		WATERP_QAN,
												DEBTL_ZNJ,
												DEBTL_ATOTAL
							FROM
							(
									SELECT		WATERP_QAN,
														DEBTL_ZNJ,
														DEBTL_ATOTAL,
														USERB_KH, 
														DEBTL_YEAR,
														DEBTL_MON
									FROM 			FH_DEBTLIST 
									WHERE  		PAY_WAY IN (' + @PAY_WAY +') AND PAY_TAG = ''' + @PAY_TAG + '''
									UNION ALL
									SELECT		WATERP_QAN,
														DEBTL_ZNJ,
														DEBTL_ATOTAL,
														USERB_KH, 
														DEBTL_YEAR,
														DEBTL_MON
									FROM 			FH_DEBTOWNHIS 
									WHERE  		PAY_WAY IN (' + @PAY_WAY +') AND PAY_TAG = ''' + @PAY_TAG + '''
							) A
							LEFT JOIN 		FH_BILLPRINT B
										ON 			A.DEBTL_YEAR != B.BILLP_YEAR AND A.DEBTL_MON != B.BILLP_MONTH AND A.USERB_KH != B.USERB_KH
					) B
			) C
					ON 1=1
	';
	--PRINT @STATEMENT;
	EXEC (@STATEMENT);
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
