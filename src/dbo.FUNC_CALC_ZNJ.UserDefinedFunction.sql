USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_CALC_ZNJ]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	功能：根据给定的年月、金额计算滞纳金
  说明：如果配置了日期，则按改日期算；如果没有，则取当前日期
**/
CREATE FUNCTION [dbo].[FUNC_CALC_ZNJ]
( 
	@DEBTL_YEAR INT,
	@DEBTL_MON INT,
	@DEBTL_ATOTAL DECIMAL(20,2),
	@PAY_BILL_DATE DATE
)
RETURNS DECIMAL(20,2) -- nvarchar
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	DECLARE @PEN_RATE FLOAT, --违约金比率
					@PEN_TYPE VARCHAR(20), --违约金类型
					@PEN_GRACEDAY INT, --宽限天数
					@PEN_MONTH INT, --间隔月份
					@PEN_ENABLED VARCHAR(2), --是否允许超出本金
					@PAY_DATE INT, --收费日
					@YQTS INT,
          @DEBTL_ZNJ DECIMAL(20,2); 
--2004.06
	IF @DEBTL_YEAR < 2004 OR (@DEBTL_YEAR = 2004 AND @DEBTL_MON <= 6)
		RETURN 0;	

	SELECT 
					@PEN_RATE = PEN_RATE,
					@PEN_TYPE = PEN_TYPE, 
					@PEN_GRACEDAY = PEN_GRACEDAY, 
					@PEN_MONTH = PEN_MONTH, 
					@PEN_ENABLED = PEN_ENABLED, 
					@PAY_DATE = PAY_DATE 	
	FROM 		FH_PENALTY;

	IF @PAY_BILL_DATE IS NULL 
		SET @PAY_BILL_DATE = GETDATE();
  

  IF @PEN_TYPE = 'wyjff02' --按天收取
		BEGIN
			SET @YQTS =
				DATEDIFF(DAY, 
								DATEADD(MONTH, 
												1, 
												CAST (@DEBTL_YEAR AS VARCHAR) + '-' + 
													CAST ((@DEBTL_MON) AS VARCHAR) + '-' + 
													CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) as VARCHAR)
								), 
								@PAY_BILL_DATE
				) - ISNULL(@PEN_GRACEDAY, 0) + 1;
    END
  ELSE
    BEGIN
			SET @YQTS =
				DATEDIFF(DAY, 
								DATEADD(MONTH, 
												@PEN_MONTH, 
												CAST (@DEBTL_YEAR AS VARCHAR) + '-' + 
													CAST (@DEBTL_MON AS VARCHAR) + '-' +
													CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) AS VARCHAR) 
								) - 1, 
								@PAY_BILL_DATE 
		   )
    END

  SET @DEBTL_ZNJ = ROUND(@DEBTL_ATOTAL * (CASE WHEN @YQTS > 0 THEN @YQTS ELSE 0 END ) * @PEN_RATE, 2);

	IF @PEN_ENABLED = 0 AND @DEBTL_ZNJ > @DEBTL_ATOTAL
		SET @DEBTL_ZNJ = @DEBTL_ATOTAL;
  
  RETURN @DEBTL_ZNJ;
END
GO
