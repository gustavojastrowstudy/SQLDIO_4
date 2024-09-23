-- Parte 1: Personalizando acessos com views

-- View 1: Número de empregados por departamento e localidade
CREATE VIEW EmpregadosPorDepartamentoLocalidade AS
SELECT d.nome_departamento, d.localidade, COUNT(e.id) AS total_empregados
FROM Empregados e
JOIN Departamentos d ON e.departamento_id = d.id
GROUP BY d.nome_departamento, d.localidade;

-- View 2: Lista de departamentos e seus gerentes
CREATE VIEW DepartamentosEGerentes AS
SELECT d.nome_departamento, e.nome AS nome_gerente
FROM Departamentos d
JOIN Empregados e ON d.gerente_id = e.id;

-- View 3: Projetos com maior número de empregados (ordenado por quantidade de empregados)
CREATE VIEW ProjetosComMaisEmpregados AS
SELECT p.nome_projeto, COUNT(ep.empregado_id) AS total_empregados
FROM Empregados_Projetos ep
JOIN Projetos p ON ep.projeto_id = p.id
GROUP BY p.nome_projeto
ORDER BY total_empregados DESC;

-- View 4: Lista de projetos, departamentos e gerentes
CREATE VIEW ProjetosDepartamentosGerentes AS
SELECT p.nome_projeto, d.nome_departamento, e.nome AS nome_gerente
FROM Projetos p
JOIN Departamentos d ON p.departamento_id = d.id
JOIN Empregados e ON d.gerente_id = e.id;

-- View 5: Quais empregados possuem dependentes e se são gerentes
CREATE VIEW EmpregadosComDependentesGerentes AS
SELECT e.nome, 
       IF(d.empregado_id IS NOT NULL, 'Sim', 'Não') AS possui_dependentes,
       IF(e.id = dep.gerente_id, 'Sim', 'Não') AS e_gerente
FROM Empregados e
LEFT JOIN Dependentes d ON e.id = d.empregado_id
LEFT JOIN Departamentos dep ON e.id = dep.gerente_id;

-- Parte 1: Definindo permissões para as views

-- Criar o usuário gerente e dar acesso às views de empregado e departamento
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON EmpregadosPorDepartamentoLocalidade TO 'gerente'@'localhost';
GRANT SELECT ON DepartamentosEGerentes TO 'gerente'@'localhost';

-- Criar o usuário empregado e restringir o acesso às views relacionadas a departamentos e gerentes
CREATE USER 'empregado'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON EmpregadosComDependentesGerentes TO 'empregado'@'localhost';

-- Parte 2: Criando gatilhos (Triggers) para e-commerce

-- Trigger 1: Trigger before delete para manter histórico de usuários que foram excluídos
CREATE TRIGGER before_delete_user
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO HistoricoUsuarios (usuario_id, nome, email, data_exclusao)
    VALUES (OLD.id, OLD.nome, OLD.email, NOW());
END;

-- Trigger 2: Trigger before update para logar atualizações de salário de empregados
CREATE TRIGGER before_update_salario
BEFORE UPDATE ON Empregados
FOR EACH ROW
BEGIN
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO HistoricoSalarios (empregado_id, salario_antigo, salario_novo, data_atualizacao)
        VALUES (OLD.id, OLD.salario, NEW.salario, NOW());
    END IF;
END;

-- Trigger 3: Trigger before insert para logar a inserção de novos empregados
CREATE TRIGGER before_insert_empregado
BEFORE INSERT ON Empregados
FOR EACH ROW
BEGIN
    INSERT INTO LogInsercaoEmpregados (empregado_id, nome, data_insercao)
    VALUES (NEW.id, NEW.nome, NOW());
END;

-- Parte 3: Backup e Recovery 

-- Backup do banco de dados e-commerce
mysqldump -u root -p --databases ecommerce > ecommerce_backup.sql

-- Restore do banco de dados a partir do backup
 mysql -u root -p ecommerce < ecommerce_backup.sql
