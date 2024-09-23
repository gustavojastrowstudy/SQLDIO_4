-- Parte 1: Criando índices em Banco de Dados

-- Índice para a consulta: Qual o departamento com maior número de pessoas?
-- Justificativa: Essa query faz uso do campo `departamento_id`, que pode ser indexado para melhorar a performance.
CREATE INDEX idx_empregados_departamento ON Empregados(departamento_id);

-- Query: Qual o departamento com maior número de pessoas?
SELECT d.nome_departamento, COUNT(e.id) AS total_empregados
FROM Empregados e
JOIN Departamentos d ON e.departamento_id = d.id
GROUP BY d.nome_departamento
ORDER BY total_empregados DESC
LIMIT 1;

-- Índice para a consulta: Quais são os departamentos por cidade?
-- Justificativa: A consulta envolve os campos `cidade` e `nome_departamento`. Um índice composto em ambos melhora a recuperação dos dados.
CREATE INDEX idx_departamentos_cidade_nome ON Departamentos(cidade, nome_departamento);

-- Query: Quais são os departamentos por cidade?
SELECT cidade, nome_departamento
FROM Departamentos
ORDER BY cidade, nome_departamento;

-- Índice para a consulta: Relação de empregados por departamento
-- Justificativa: A consulta usa `departamento_id` e `nome` para buscar e organizar os dados, sendo um bom candidato para um índice composto.
CREATE INDEX idx_empregados_departamento_nome ON Empregados(departamento_id, nome);

-- Query: Relação de empregados por departamento
SELECT d.nome_departamento, e.nome
FROM Empregados e
JOIN Departamentos d ON e.departamento_id = d.id
ORDER BY d.nome_departamento, e.nome;

-- Parte 2: Utilização de procedures para manipulação de dados

-- Criando uma procedure para manipulação de dados na tabela Empregados
-- Justificativa: A procedure abaixo realiza as operações de inserção, atualização, remoção e seleção com base no valor de controle passado como parâmetro.

DELIMITER $$

CREATE PROCEDURE ManipularEmpregados (
    IN p_acao INT,
    IN p_empregado_id INT,
    IN p_nome VARCHAR(100),
    IN p_departamento_id INT,
    IN p_salario DECIMAL(10, 2)
)
BEGIN
    -- Ação 1: Inserir um novo empregado
    IF p_acao = 1 THEN
        INSERT INTO Empregados (nome, departamento_id, salario)
        VALUES (p_nome, p_departamento_id, p_salario);
        
    -- Ação 2: Atualizar um empregado existente
    ELSEIF p_acao = 2 THEN
        UPDATE Empregados
        SET nome = p_nome, departamento_id = p_departamento_id, salario = p_salario
        WHERE id = p_empregado_id;
        
    -- Ação 3: Remover um empregado (remoção lógica, atualizando o campo is_ativo para 0)
    ELSEIF p_acao = 3 THEN
        UPDATE Empregados
        SET is_ativo = 0
        WHERE id = p_empregado_id;
        
    -- Ação 4: Selecionar empregado pelo ID
    ELSEIF p_acao = 4 THEN
        SELECT * FROM Empregados WHERE id = p_empregado_id;
        
    -- Ação padrão: Caso valor inválido seja passado
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ação inválida!';
    END IF;
END $$

DELIMITER ;

-- Chamadas para a procedure

-- 1. Inserir um novo empregado
CALL ManipularEmpregados(1, NULL, 'João Silva', 2, 3500.00);

-- 2. Atualizar um empregado existente
CALL ManipularEmpregados(2, 5, 'Maria Souza', 3, 4200.00);

-- 3. Remover um empregado
CALL ManipularEmpregados(3, 5, NULL, NULL, NULL);

-- 4. Selecionar um empregado pelo ID
CALL ManipularEmpregados(4, 5, NULL, NULL, NULL);

-- Parte 2: Utilização de procedure para e-commerce (Exemplo com a tabela de Produtos)

DELIMITER $$

CREATE PROCEDURE ManipularProdutos (
    IN p_acao INT,
    IN p_produto_id INT,
    IN p_nome VARCHAR(100),
    IN p_preco DECIMAL(10, 2),
    IN p_categoria_id INT
)
BEGIN
    -- Ação 1: Inserir um novo produto
    IF p_acao = 1 THEN
        INSERT INTO Produtos (nome, preco, categoria_id)
        VALUES (p_nome, p_preco, p_categoria_id);
        
    -- Ação 2: Atualizar um produto existente
    ELSEIF p_acao = 2 THEN
        UPDATE Produtos
        SET nome = p_nome, preco = p_preco, categoria_id = p_categoria_id
        WHERE id = p_produto_id;
        
    -- Ação 3: Remover um produto (remoção lógica)
    ELSEIF p_acao = 3 THEN
        UPDATE Produtos
        SET is_ativo = 0
        WHERE id = p_produto_id;
        
    -- Ação 4: Selecionar produto pelo ID
    ELSEIF p_acao = 4 THEN
        SELECT * FROM Produtos WHERE id = p_produto_id;
        
    -- Ação padrão: Caso valor inválido seja passado
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ação inválida!';
    END IF;
END $$

DELIMITER ;

-- Chamadas para a procedure

-- 1. Inserir um novo produto
CALL ManipularProdutos(1, NULL, 'Notebook Gamer', 5500.00, 1);

-- 2. Atualizar um produto existente
CALL ManipularProdutos(2, 10, 'Monitor 4K', 1500.00, 2);

-- 3. Remover um produto
CALL ManipularProdutos(3, 10, NULL, NULL, NULL);

-- 4. Selecionar um produto pelo ID
CALL ManipularProdutos(4, 10, NULL, NULL, NULL);
