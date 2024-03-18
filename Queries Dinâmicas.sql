USE MASTER
GO
DROP DATABASE QueriesDinamicas
GO
CREATE DATABASE QueriesDinamicas
GO
USE QueriesDinamicas
GO
CREATE TABLE PRODUTO (
Codigo				INT				NOT NULL,
Nome				VARCHAR(100)	NOT NULL,
Valor				DECIMAL(7, 2)	NOT NULL
PRIMARY KEY(Codigo)
)
GO

CREATE TABLE ENTRADA (
Codigo_Transacao	VARCHAR(3)		NOT NULL,
Codigo_Produto		INT				NOT NULL,
Quantidade			INT				NOT NULL,
Valor_Total			DECIMAL(7, 2)	NOT NULL
PRIMARY KEY(Codigo_Transacao)
FOREIGN KEY (Codigo_Produto) REFERENCES PRODUTO(Codigo))
GO

CREATE TABLE SAIDA (
Codigo_Transacao	VARCHAR(3)		NOT NULL,
Codigo_Produto		INT				NOT NULL,
Quantidade			INT				NOT NULL,
Valor_Total			DECIMAL(7, 2)	NOT NULL
PRIMARY KEY(Codigo_Transacao)
FOREIGN KEY (Codigo_Produto) REFERENCES PRODUTO(Codigo))
GO

CREATE PROCEDURE sp_RegistraTransacao (@codigo CHAR(1), @codigo_transacao INT,
				@codigo_produto INT, @quantidade INT,
				@saida VARCHAR(200) OUTPUT)
AS
	DECLARE @tabela VARCHAR(10)

	IF (LOWER(@codigo) = 'e')
	BEGIN
		SET @tabela = 'entrada'
	END
	ELSE
	IF (LOWER(@codigo) = 's')
	BEGIN
		SET @tabela = 'saida'
	END
	ELSE
	BEGIN
		RAISERROR('Código inválido', 16, 1)
	END

	IF (@tabela IS NOT NULL)
	BEGIN
	

		DECLARE @valor_total DECIMAL(7, 2)
		DECLARE @query VARCHAR(200)

		SELECT @valor_total = valor FROM produto WHERE codigo = @codigo_produto
		IF (@valor_total IS NOT NULL AND @quantidade > 0)
		BEGIN
			SET @valor_total = @valor_total * @quantidade

			SET @query = 'INSERT INTO ' + @tabela + ' VALUES (' + 
				CAST(@codigo_transacao AS VARCHAR(5)) + ', ' +
				CAST(@codigo_produto AS VARCHAR(5)) + ', ' +
				CAST(@quantidade AS VARCHAR(5)) + ', ' + 
				CAST(@valor_total AS VARCHAR(10)) + ')'
			BEGIN TRY
				EXEC (@query)
				SET @saida = 'Inserido na tabela ' + @tabela + ' com sucesso!'
			END TRY
			BEGIN CATCH
				DECLARE @erro VARCHAR(100)
				SET @erro = ERROR_MESSAGE()
				IF (@erro LIKE '%primary%')
				BEGIN
					SET @erro = 'Esta transação já possui este produto cadastrado'
				END
				ELSE
				BEGIN
					SET @erro = 'Ocorreu um erro ao inserir esta transação no BD'
				END
				RAISERROR(@erro, 16, 1)
			END CATCH
		END
	END