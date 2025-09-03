-- SELECT Q1 Motivo: Essa consulta lista todas as exibições organizadas pelo cineclube, permitindo acompanhamento de eventos passados e futuros.

select titulo, data, local from acoes where tipo = 'exibição' order by data desc;

-- VIEW Q2 Cria uma visão consolidada dos eventos com o responsável interno associado, facilitando relatórios sem precisar recriar a query toda vez.

create view vw_eventos_completo as
select a.titulo, a.tipo, a.data, a.local, u.nome as responsavel
from acoes a
join usuario u on u.email = (select email from publico where publico_interno = 1 limit 1);

-- PROCEDURE Q3 Automatiza o cadastro de novas ações do cineclube, evitando repetição de comandos INSERT e reduzindo erros.

delimiter //
create procedure cadastrar_acao (
    in p_tipo varchar(20),
    in p_titulo varchar(50),
    in p_data date,
    in p_inicio time,
    in p_fim time,
    in p_local varchar(75)
)
begin
    insert into acoes (tipo, titulo, data, hora_inicio, hora_fim, local)
    values (p_tipo, p_titulo, p_data, p_inicio, p_fim, p_local);
end //
delimiter ;

-- FUNCTION Q4 Função para calcular a duração (em minutos) de cada exibição ou evento. Isso ajuda a organizar a agenda e saber a carga horária cultural.

delimiter //
create function calcular_duracao(h_inicio time, h_fim time)
returns int
deterministic
begin
    return time_to_sec(timediff(h_fim, h_inicio)) / 60;
end //
delimiter ;

-- TRIGGER Q5 Sempre que um novo usuário for cadastrado, ele já é registrado como público interno automaticamente. Isso garante consistência no banco sem depender de ações manuais.

delimiter //
create trigger log_novo_usuario
after insert on usuario
for each row
begin
    insert into publico (email, publico_externo, publico_interno)
    values (new.email, 0, 1);
end //
delimiter ;