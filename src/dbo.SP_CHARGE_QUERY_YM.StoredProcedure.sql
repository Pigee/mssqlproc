USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_CHARGE_QUERY_YM]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：根据用户卡号、年月查找用户欠费金额及滞纳金
  说明：如果用户账单在fh_debtlist中，则不计算滞纳金；如果用户数据在fh_debtownhis中则需要计算
        滞纳金。目前根据单条账单总金额计算滞纳金，计算方法为查找FH_PENALTY表中的数据，如果有
        配置天数，则优先按天数收取；如果没有天数则按月来收
  备注：改功能与sp_charge_query相似，只是加了年月过滤条件
  author： junlong&QY.lin
**/
CREATE PROCEDURE [dbo].[SP_CHARGE_QUERY_YM](@USERB_KH VARCHAR(36), @DEBTL_YEAR INT, @DEBTL_MON INT)
AS
BEGIN

		DECLARE @PEN_RATE FLOAT, 
					@PEN_TYPE VARCHAR(20), 
					@PEN_GRACEDAY INT, 
					@PEN_MONTH INT, 
					@PEN_ENABLED VARCHAR(2),
					@PAY_DATE INT;
			
			SELECT 
							@PEN_RATE = PEN_RATE,
							@PEN_TYPE = PEN_TYPE, 
							@PEN_GRACEDAY = PEN_GRACEDAY, 
							@PEN_MONTH = PEN_MONTH, 
							@PEN_ENABLED = PEN_ENABLED, 
							@PAY_DATE = PAY_DATE 	
			FROM 		FH_PENALTY;
			
			--优先按天收取
			IF @PEN_TYPE = 'wyjff02' --按天收取
				BEGIN
					 SELECT DEBTLIST_ID, USERB_KH, VOLUME_NO,DEBTL_YEAR,DEBTL_MON,USERB_SQDS,
									USERB_BQDS,RECORD_DATE,DEBTL_STOTAL,YQTS,CONVERT(varchar(100),ROUND(YSWYJ, 2)),
									CONVERT(varchar(100),ROUND(JMWYJ + ALT_QAN, 2)) JMWYJ,CONVERT(varchar(100),ROUND(YSWYJ - ALT_QAN, 2)) SSWYJ, 
									CONVERT(varchar(100),ROUND(HJ - ALT_QAN, 2)) HJ,BANK_DEALTAG
					 FROM (
           SELECT a.*, ISNULL(SUM(b.ALT_QAN), 0) ALT_QAN FROM (
					 SELECT t.DEBTLIST_ID,
									t.USERB_KH,
									t.VOLUME_NO,
									t.DEBTL_YEAR,
									t.DEBTL_MON,
									t.USERB_SQDS,
									t.USERB_BQDS,
									CONVERT(varchar(100), t.RECORD_DATE, 23) RECORD_DATE,
									t.DEBTL_STOTAL,
									0 YQTS,
									0 YSWYJ,
									0 JMWYJ,
									0 SSWYJ,
									t.DEBTL_ATOTAL HJ,
									T.BANK_DEALTAG
					 FROM   FH_DEBTLIST T
					 WHERE  T.DEBTL_ATOTAL > 0
									AND( T.PAY_TAG = '0' OR T.PAY_TAG IS NULL)
									AND T.DEBTL_YEAR = @DEBTL_YEAR AND T.DEBTL_MON = @DEBTL_MON
									AND T.USERB_KH = @USERB_KH
           UNION ALL
					 SELECT
							t1.DEBTLIST_ID,
							t1.USERB_KH,
							t1.VOLUME_NO,
							t1.DEBTL_YEAR,
							t1.DEBTL_MON,
							t1.USERB_SQDS,
							t1.USERB_BQDS,
							CONVERT(varchar(100), t1.RECORD_DATE, 23) RECORD_DATE,
							--t1.RECORD_DATE,
							t1.DEBTL_STOTAL,
							T2.YQTS,
							CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
											t1.DEBTL_STOTAL
									 ELSE
											T2.DEBTL_ZNJ
							END YSWYS,
							0 JMWYS,
							0 SSWYJ,
							CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
											t1.DEBTL_ATOTAL + t1.DEBTL_STOTAL
									 ELSE
											T2.DEBTL_ZNJ + t1.DEBTL_ATOTAL
							END HJ,
							T1.BANK_DEALTAG
					FROM  FH_DEBTOWNHIS T1, 
							(
									SELECT 	T3.DEBTLIST_ID,
													case when T3.YQTS > 0 then T3.YQTS else 0 end YQTS ,
													round(T3.DEBTL_STOTAL * (case when T3.YQTS > 0 then T3.YQTS else 0 end) * @PEN_RATE, 2) DEBTL_ZNJ
									FROM (
											SELECT 	DEBTLIST_ID,
															DEBTL_STOTAL,
															DATEDIFF(DAY, 
																--下个月1号开始计算
																DATEADD(MONTH, 1, CAST (DEBTL_YEAR AS VARCHAR) + '-' + CAST ((DEBTL_MON) AS VARCHAR) + '-' + 
																	CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) as VARCHAR)), GETDATE()) 
																- ISNULL(@PEN_GRACEDAY, 0)
																YQTS
											FROM 		FH_DEBTOWNHIS
											WHERE 	DEBTL_ATOTAL > 0 AND DEBTL_YEAR = @DEBTL_YEAR AND DEBTL_MON = @DEBTL_MON AND USERB_KH = @USERB_KH 
									) T3
							) 	T2
					WHERE T1.DEBTLIST_ID = T2.DEBTLIST_ID
						AND T1.DEBTL_ATOTAL > 0
						AND( T1.PAY_TAG = '0' OR T1.PAY_TAG IS NULL)
						AND T1.DEBTL_YEAR = @DEBTL_YEAR AND T1.DEBTL_MON = @DEBTL_MON
            AND T1.USERB_KH = @USERB_KH
					) a 
					LEFT JOIN FH_PAYALT b
					ON a.DEBTLIST_ID = b.DEBTL_ID and b.ALT_TYPE = '1'
					GROUP BY a.DEBTLIST_ID, a.USERB_KH, a.VOLUME_NO,a.DEBTL_YEAR,a.DEBTL_MON,a.USERB_SQDS,
									a.USERB_BQDS,a.RECORD_DATE,a.DEBTL_STOTAL,a.YQTS,a.YSWYJ,a.JMWYJ,
									a.SSWYJ,a.HJ,a.BANK_DEALTAG
					) d
          ORDER BY d.DEBTL_YEAR ASC, d.DEBTL_MON ASC
				END
      ELSE --按月份收取
        BEGIN
					 SELECT DEBTLIST_ID, USERB_KH, VOLUME_NO,DEBTL_YEAR,DEBTL_MON,USERB_SQDS,
									USERB_BQDS,RECORD_DATE,DEBTL_STOTAL,YQTS,CONVERT(varchar(100),ROUND(YSWYJ, 2)) YSWYJ,
									CONVERT(varchar(100),ROUND(JMWYJ + ALT_QAN,2)) JMWYJ, CONVERT(varchar(100),ROUND(YSWYJ - ALT_QAN, 2)) SSWYJ,
									CONVERT(varchar(100),ROUND(HJ - ALT_QAN, 2)) HJ,BANK_DEALTAG
					 FROM (
           SELECT a.*, ISNULL(SUM(b.ALT_QAN), 0) ALT_QAN FROM (
					 SELECT t.DEBTLIST_ID,
									t.USERB_KH,
									t.VOLUME_NO,
									t.DEBTL_YEAR,
									t.DEBTL_MON,
									t.USERB_SQDS,
									t.USERB_BQDS,
									CONVERT(varchar(100), t.RECORD_DATE, 23) RECORD_DATE,
									t.DEBTL_STOTAL,
									0 YQTS,
									0 YSWYJ,
									0 JMWYJ,
									0 SSWYJ,
									t.DEBTL_ATOTAL HJ,
									T.BANK_DEALTAG
					 FROM   FH_DEBTLIST T
					 WHERE  T.DEBTL_ATOTAL > 0
									AND( T.PAY_TAG = '0' OR T.PAY_TAG IS NULL)
									AND T.DEBTL_YEAR = @DEBTL_YEAR AND T.DEBTL_MON = @DEBTL_MON
                  AND T.USERB_KH = @USERB_KH
           UNION ALL
					 SELECT
							t1.DEBTLIST_ID,
							t1.USERB_KH,
							t1.VOLUME_NO,
							t1.DEBTL_YEAR,
							t1.DEBTL_MON,
							t1.USERB_SQDS,
							t1.USERB_BQDS,
							CONVERT(varchar(100), t1.RECORD_DATE, 23) RECORD_DATE,
							t1.DEBTL_STOTAL,
							T2.YQTS,
							CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
											t1.DEBTL_STOTAL
									 ELSE
											T2.DEBTL_ZNJ
							END YSWYS,
							0 JMWYS,
							0 SSWYJ,
							CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
											t1.DEBTL_ATOTAL + t1.DEBTL_STOTAL
									 ELSE
											T2.DEBTL_ZNJ + t1.DEBTL_ATOTAL
							END HJ,
							T1.BANK_DEALTAG
					FROM  FH_DEBTOWNHIS T1, 
							(
									SELECT 	T3.DEBTLIST_ID,
													YQTS,
													round(T3.DEBTL_STOTAL * T3.YQTS * @PEN_RATE, 2) DEBTL_ZNJ
									FROM (
											SELECT 	DEBTLIST_ID,
															DEBTL_STOTAL,
															
															DATEDIFF(DAY, 
																
															 DATEADD(MONTH, @PEN_MONTH, CAST (DEBTL_YEAR AS VARCHAR) + '-' + CAST (DEBTL_MON AS VARCHAR) + '-' +
																CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) AS VARCHAR) ), 
																GETDATE() ) 
																
																YQTS
											FROM 		FH_DEBTOWNHIS
											WHERE 	DEBTL_ATOTAL > 0 AND DEBTL_YEAR = @DEBTL_YEAR AND DEBTL_MON = @DEBTL_MON AND USERB_KH = @USERB_KH 
									) T3
							) 	T2
					WHERE T1.DEBTLIST_ID = T2.DEBTLIST_ID
						AND T1.DEBTL_ATOTAL > 0
						AND( T1.PAY_TAG = '0' OR T1.PAY_TAG IS NULL)
						AND T1.DEBTL_YEAR = @DEBTL_YEAR AND T1.DEBTL_MON = @DEBTL_MON
            AND T1.USERB_KH = @USERB_KH
				  ) a 
					LEFT JOIN FH_PAYALT b
					ON a.DEBTLIST_ID = b.DEBTL_ID and b.ALT_TYPE = '1'
					GROUP BY a.DEBTLIST_ID, a.USERB_KH, a.VOLUME_NO,a.DEBTL_YEAR,a.DEBTL_MON,a.USERB_SQDS,
									a.USERB_BQDS,a.RECORD_DATE,a.DEBTL_STOTAL,a.YQTS,a.YSWYJ,a.JMWYJ,
									a.SSWYJ,a.HJ,a.BANK_DEALTAG
					) d
          ORDER BY d.DEBTL_YEAR ASC, d.DEBTL_MON ASC
				END

			
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
