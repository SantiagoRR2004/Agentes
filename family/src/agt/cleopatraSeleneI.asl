// Agent cleopatraSeleneI in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyVIII, cleopatraSeleneI).
es_madre_de(cleopatraIII, cleopatraSeleneI).

divorciados(cleopatraSeleneI, ptolemyIX).
es_madre_de(cleopatraSeleneI, bereniceIII).

casadoCon(cleopatraSeleneI, ptolemyX).
es_madre_de(cleopatraSeleneI, ptolemyXI).

/* Initial goals */


/* Plans for events and intentions */

