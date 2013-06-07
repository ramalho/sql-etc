#!/usr/bin/env python
# coding: utf-8

import sqlite3
from contextlib import closing

DDL = '''
CREATE TABLE especialidades (
    sigla STRING PRIMARY KEY,
    descricao STRING NOT NULL
);
CREATE TABLE medicos (
    nome STRING PRIMARY KEY,
    sigla STRING
);

'''

DATA = {
    'especialidades' :
    [   {'sigla': 'CRD', 'descricao': 'cardiologia'},
        {'sigla': 'NRO', 'descricao': 'neurologia'},
        {'sigla': 'PSQ', 'descricao': 'psiquiatria'},
        {'sigla': 'ORT', 'descricao': 'ortopedia'}
    ],
    'medicos' :
    [   {'nome': 'Gomes', 'sigla': 'PSQ'},
        {'nome': 'Silva', 'sigla': 'CRD'},
        {'nome': 'Bruck', 'sigla': 'ORT'},
        {'nome': 'Souza', 'sigla': 'ORT'},
        {'nome': 'Alves', 'sigla': 'CRD'},
        {'nome': 'Moura', 'sigla': None}
    ]
}


def criar_bd(cnx):
    cnx.executescript(DDL)
    cnx.commit()

def carregar(cnx):
    especialidades = [(e['sigla'], e['descricao']) for e in DATA['especialidades']]
    cnx.executemany('INSERT INTO especialidades VALUES (?,?)', especialidades)
    medicos = [(m['nome'], m['sigla']) for m in DATA['medicos']]
    cnx.executemany('INSERT INTO medicos VALUES (?,?)', medicos)



consultas = {
    'especialidades' :
                ''' SELECT sigla, descricao FROM especialidades''',
    'medicos' : ''' SELECT nome, sigla FROM medicos''',

    # cross join (produto cartesiano)
    'cross' :   ''' SELECT * FROM medicos, especialidades''',

    # cross explícito
    'cross2' :   ''' SELECT * FROM medicos CROSS JOIN especialidades''',

    # inner join implícito
    'inner' :   ''' SELECT * FROM medicos, especialidades
                        WHERE medicos.sigla = especialidades.sigla''',
    # inner join explícito

    'inner2' :  ''' SELECT * FROM medicos
                        INNER JOIN especialidades
                        ON medicos.sigla = especialidades.sigla''',

    # natural join
    'natural' : ''' SELECT * FROM medicos
                        NATURAL JOIN especialidades''',

    # left outer join
    'left_outer' : '''  SELECT *
                            FROM medicos LEFT OUTER JOIN especialidades
                            ON medicos.sigla = especialidades.sigla''',

    # right outer join (não implementado no SQLite)
    'right_outer' : '''  SELECT *
                            FROM medicos RIGHT OUTER JOIN especialidades
                            ON medicos.sigla = especialidades.sigla''',

    # left outer join (equivale ao right outer join acima)
    'left_outer2' : '''  SELECT *
                            FROM especialidades LEFT OUTER JOIN medicos
                            ON medicos.sigla = especialidades.sigla''',

}

def equivalente(r1, r2):
    return {frozenset(t1) for t1 in r1} == {frozenset(t2) for t2 in r2}

def main(argv):
    consulta = argv[1]
    with closing(sqlite3.connect(':memory:')) as cnx:
        criar_bd(cnx)
        carregar(cnx)
        res = cnx.execute(consultas[consulta])
        for campos in res:
            print campos
        # print equivalente(cnx.execute(consultas['ijoin']), cnx.execute(consultas['ijoin2']))

if __name__=='__main__':
    import sys
    main(sys.argv)
