CREATE FUNCTION [dbo].[fnBase64Encode]
(
	@plain_text varchar(6000)
)
RETURNS varchar(8000)
AS
BEGIN
	--local variables
	DECLARE	@output            varchar(8000),
			@input_length      integer,
			@block_start       integer,
			@partial_block_start  integer, -- position of last 0, 1 or 2 characters
			@partial_block_length integer,
			@block_val         integer,
			@map               char(64)
	SET @map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	--initialise variables
	SET @output   = ''
	--set length and count
	SET @input_length      = LEN( @plain_text + '#' ) - 1
	SET @partial_block_length = @input_length % 3
	SET @partial_block_start = @input_length - @partial_block_length
	SET @block_start       = 1
	--for each block
	WHILE @block_start < @partial_block_start  
	BEGIN
		SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, 3) AS BINARY(3))
		--encode the 3 character block and add to the output
		SET @output = @output + SUBSTRING(@map, @block_val / 262144 + 1, 1)
			                + SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
			                + SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1)
			                + SUBSTRING(@map, (@block_val & 63) + 1, 1)
		--increment the counter
		SET @block_start = @block_start + 3
	END
	IF @partial_block_length > 0
	BEGIN
		SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, @partial_block_length)
							+ REPLICATE(CHAR(0), 3 - @partial_block_length) AS BINARY(3))
		SET @output = @output
			+ SUBSTRING(@map, @block_val / 262144 + 1, 1)
			+ SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
			+ CASE WHEN @partial_block_length < 2 THEN 
				REPLACE(SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1), 'A', '=')
			ELSE 
				SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1) 
			END
			+ CASE WHEN @partial_block_length < 3 THEN 
				REPLACE(SUBSTRING(@map, (@block_val & 63) + 1, 1), 'A', '=')
			ELSE 
				SUBSTRING(@map, (@block_val & 63) + 1, 1) 
			END
	END
	--return the result
	RETURN @output
END
