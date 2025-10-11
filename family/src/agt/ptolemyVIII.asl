// Agent ptolemyVIII in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyV, ptolemyVIII).
es_madre_de(cleopatraI, ptolemyVIII).

divorciados(ptolemyVIII, cleopatraII).
es_padre_de(ptolemyVIII, ptolemyVII).

casadoCon(ptolemyVIII, cleopatraIII).
es_padre_de(ptolemyVIII, cleopatraIV).
es_padre_de(ptolemyVIII, ptolemyIX).
es_padre_de(ptolemyVIII, cleopatraSeleneI).
es_padre_de(ptolemyVIII, ptolemyX).

/* Initial goals */


/* Plans for events and intentions */

