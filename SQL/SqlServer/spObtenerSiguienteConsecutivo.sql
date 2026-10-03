IF OBJECT_ID('dbo.spObtenerSiguienteConsecutivo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spObtenerSiguienteConsecutivo;
GO

CREATE PROCEDURE dbo.spObtenerSiguienteConsecutivo
    @p_transaction_type NVARCHAR(50),
    @p_branch_id INT = NULL,
    @p_implant_id INT = NULL,
    @p_formatted_consecutive NVARCHAR(100) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_norm_type NVARCHAR(50) = UPPER(LTRIM(RTRIM(ISNULL(@p_transaction_type, 'INVOICE'))));
    DECLARE @v_id INT = NULL;
    DECLARE @v_next_val INT = NULL;
    DECLARE @v_prefix NVARCHAR(20) = '';
    DECLARE @v_padding INT = 0;
    DECLARE @v_num_str NVARCHAR(50);
    
    -- 1. Buscar en TransactionConsecutive si la tabla existe
    IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
    BEGIN
        SELECT TOP 1 
            @v_id = id,
            @v_next_val = ISNULL(currentNumber, ISNULL(initialNumber, 1)),
            @v_prefix = ISNULL(LTRIM(RTRIM(prefix)), ''),
            @v_padding = ISNULL(padding, 0)
        FROM dbo.[TransactionConsecutive] WITH (UPDLOCK, ROWLOCK)
        WHERE isActive = 1
          AND (
              UPPER(transactionType) = @v_norm_type
              OR (@v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA') AND UPPER(transactionType) IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA'))
              OR (@v_norm_type IN ('QUOTATION', 'COTIZACION') AND UPPER(transactionType) IN ('QUOTATION', 'COTIZACION'))
              OR (@v_norm_type IN ('PREQUOTATION', 'PRECOTIZACION') AND UPPER(transactionType) IN ('PREQUOTATION', 'PRECOTIZACION'))
              OR (@v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') AND UPPER(transactionType) IN ('CREDIT_NOTE', 'NOTA_CREDITO'))
          )
          AND (@p_branch_id IS NULL OR branchId IS NULL OR branchId = @p_branch_id)
          AND (@p_implant_id IS NULL OR implantId IS NULL OR implantId = @p_implant_id)
        ORDER BY 
            CASE WHEN @p_implant_id IS NOT NULL AND implantId = @p_implant_id THEN 1 WHEN implantId IS NOT NULL THEN 3 ELSE 2 END,
            CASE WHEN @p_branch_id IS NOT NULL AND branchId = @p_branch_id THEN 1 WHEN branchId IS NOT NULL THEN 3 ELSE 2 END,
            id ASC;
    END;
        
    IF @v_id IS NOT NULL
    BEGIN
        UPDATE dbo.[TransactionConsecutive]
        SET currentNumber = currentNumber + 1,
            updatedAt = GETDATE()
        WHERE id = @v_id;
    END
    ELSE
    BEGIN
        SET @v_prefix = CASE 
            WHEN @v_norm_type IN ('QUOTATION', 'COTIZACION') THEN 'COT'
            WHEN @v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION') THEN 'FAC'
            WHEN @v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') THEN 'NC'
            ELSE 'DOC'
        END;
        
        IF @v_norm_type IN ('QUOTATION', 'COTIZACION')
        BEGIN
            IF OBJECT_ID('dbo.Quotation', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Quotation];
            ELSE
                SET @v_next_val = 1;
        END
        ELSE
        BEGIN
            IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Invoices];
            ELSE
                SET @v_next_val = 1;
        END;
    END;
    
    SET @v_num_str = CAST(ISNULL(@v_next_val, 1) AS NVARCHAR(50));
    IF @v_padding > 0 AND LEN(@v_num_str) < @v_padding
        SET @v_num_str = RIGHT(REPLICATE('0', @v_padding) + @v_num_str, @v_padding);
        
    IF @v_prefix <> ''
    BEGIN
        IF RIGHT(@v_prefix, 1) IN ('-', '/')
            SET @p_formatted_consecutive = @v_prefix + @v_num_str;
        ELSE
            SET @p_formatted_consecutive = @v_prefix + '-' + @v_num_str;
    END
    ELSE
        SET @p_formatted_consecutive = @v_num_str;
END;
GO
