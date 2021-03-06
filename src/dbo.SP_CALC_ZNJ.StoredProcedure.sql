USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_CALC_ZNJ]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：根据用户卡号查找用户欠费金额及滞纳金
  说明：如果用户账单在fh_debtlist中，则不计算滞纳金；如果用户数据在fh_debtownhis中则需要计算
        滞纳金。目前根据单条账单总金额计算滞纳金，计算方法为查找FH_PENALTY表中的数据，如果有
        配置天数，则优先按天数收取；如果没有天数则按月来收
  author： junlong&QY.lin
**/
CREATE PROCEDURE [dbo].[SP_CALC_ZNJ](@USERB_KH VARCHAR(36))
AS
BEGIN
			DECLARE @PEN_RATE FLOAT, --违约金比率
					@PEN_TYPE VARCHAR(20), --违约金类型
					@PEN_GRACEDAY INT, --宽限天数
					@PEN_MONTH INT, --间隔月份
					@PEN_ENABLED VARCHAR(2), --是否允许超出本金
					@PAY_DATE INT; --收费日
			
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
					 SELECT SUM(ROUND(YSWYJ - ALT_QAN, 2)) WYJ,
									SUM(ROUND(HJ - ALT_QAN, 2)) HJ
					 FROM ( -- level 1
							SELECT a.*, ISNULL(SUM(b.ALT_QAN), 0) ALT_QAN 
							FROM -- level 2
							(
								 -- 应收账单表为当月数据，不收取滞纳金
								 SELECT t.DEBTLIST_ID,
												0 YSWYJ,
												t.DEBTL_ATOTAL HJ
								 FROM   FH_DEBTLIST T
								 WHERE  T.DEBTL_ATOTAL > 0
												AND( T.PAY_TAG = '0' OR T.PAY_TAG IS NULL)
												AND T.USERB_KH = @USERB_KH
								UNION ALL
                -- 欠费表中的记录需要计算滞纳金
								 SELECT 
                    T1.DEBTLIST_ID,
										-- 判断是否允许超出本金
										CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
														t1.DEBTL_STOTAL
												 ELSE
														T2.DEBTL_ZNJ
										END YSWYS,
										CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
														t1.DEBTL_ATOTAL + t1.DEBTL_STOTAL
												 ELSE
														T2.DEBTL_ZNJ + t1.DEBTL_ATOTAL
										END HJ
								FROM  FH_DEBTOWNHIS T1, 
								( --level 3
										SELECT 	T3.DEBTLIST_ID,
														round(T3.DEBTL_STOTAL * (case when T3.YQTS > 0 then T3.YQTS else 0 end) * @PEN_RATE, 2) DEBTL_ZNJ
										FROM ( --level 4
												SELECT 	DEBTLIST_ID,
																DEBTL_STOTAL,
																--从下个月的收费日开始计算逾期天数 - 宽限天数
																DATEDIFF(DAY, 
																				DATEADD(MONTH, 
																								1, 
																								CAST (DEBTL_YEAR AS VARCHAR) + '-' + CAST ((DEBTL_MON) AS VARCHAR) + '-' + CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) as VARCHAR)), 
																				GETDATE()) 
																- ISNULL(@PEN_GRACEDAY, 0) + 1
																YQTS
												FROM 		FH_DEBTOWNHIS
												WHERE 	DEBTL_ATOTAL > 0 AND USERB_KH = @USERB_KH 
										) T3 --end level 4
								) 	T2 --end level 3
							WHERE T1.DEBTLIST_ID = T2.DEBTLIST_ID
								AND T1.DEBTL_ATOTAL > 0
								AND( T1.PAY_TAG = '0' OR T1.PAY_TAG IS NULL)
								AND T1.USERB_KH = @USERB_KH
						) a  -- end level 2
						LEFT JOIN FH_PAYALT b
						ON a.DEBTLIST_ID = b.DEBTL_ID and b.ALT_TYPE = '1'
						GROUP BY A.DEBTLIST_ID,a.YSWYJ,a.HJ
					) d -- end level 1
				END
      ELSE --按月份收取
        BEGIN
					 SELECT SUM(ROUND(YSWYJ - ALT_QAN, 2)) WYJ,
									SUM(ROUND(HJ - ALT_QAN, 2)) HJ
					 FROM (
						 SELECT a.*, ISNULL(SUM(b.ALT_QAN), 0) ALT_QAN 
						 FROM 
						 (
								 SELECT t.DEBTLIST_ID,
												0 YSWYJ,
												t.DEBTL_ATOTAL HJ
								 FROM   FH_DEBTLIST T
								 WHERE  T.DEBTL_ATOTAL > 0
												AND( T.PAY_TAG = '0' OR T.PAY_TAG IS NULL)
												AND T.USERB_KH = @USERB_KH
								 UNION ALL
								 SELECT
										t1.DEBTLIST_ID,
										CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
														t1.DEBTL_STOTAL
												 ELSE
														T2.DEBTL_ZNJ
										END YSWYS,
										CASE  WHEN @PEN_ENABLED = 0 AND T2.DEBTL_ZNJ > t1.DEBTL_STOTAL THEN
														t1.DEBTL_ATOTAL + t1.DEBTL_STOTAL
												 ELSE
														T2.DEBTL_ZNJ + t1.DEBTL_ATOTAL
										END HJ
								FROM  FH_DEBTOWNHIS T1, 
								(
										SELECT 	T3.DEBTLIST_ID,
														round(T3.DEBTL_STOTAL * T3.YQTS * @PEN_RATE, 2) DEBTL_ZNJ
										FROM (
														SELECT 	DEBTLIST_ID,
																		DEBTL_STOTAL,
																		
																		DATEDIFF(DAY, 
																			
																		 DATEADD(MONTH, 
																						@PEN_MONTH, 
																						CAST (DEBTL_YEAR AS VARCHAR) + '-' + CAST (DEBTL_MON AS VARCHAR) + '-' +
																							CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) AS VARCHAR) ) - 1, 
																			GETDATE() )  
																			
																			YQTS
														FROM 		FH_DEBTOWNHIS
														WHERE 	DEBTL_ATOTAL > 0 AND USERB_KH = @USERB_KH 
										) T3
								) 	T2
								WHERE T1.DEBTLIST_ID = T2.DEBTLIST_ID
									AND T1.DEBTL_ATOTAL > 0
									AND( T1.PAY_TAG = '0' OR T1.PAY_TAG IS NULL)
									AND T1.USERB_KH = @USERB_KH
						) a 
						LEFT JOIN FH_PAYALT b
						ON a.DEBTLIST_ID = b.DEBTL_ID and b.ALT_TYPE = '1'
						GROUP BY A.DEBTLIST_ID,a.YSWYJ,a.HJ
					) d
				END

			

  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
