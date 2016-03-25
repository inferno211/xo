#include <a_samp>
#include <sscanf2>
#include <zcmd>

#define SCM SendClientMessage
#define SCMA SendClientMessageToAll


new Text: i_xo[7];
new Text: i_xo_a[3][3];


#define XO_X		0
#define XO_O		1
#define XO_NONE 	2

new i_xo_plansza[3][3] =
{
//		0		1		2
	{XO_NONE, XO_NONE, XO_NONE},
//		3		4		5
	{XO_NONE, XO_NONE, XO_NONE},
//		6		7		8
	{XO_NONE, XO_NONE, XO_NONE}
};

enum E_I_XO
{
	bool: i_trwa,
	opo[2],
	ruch,
	zaznaczonych,
	znaki[2]
}
new xo_info[E_I_XO];

CMD:xostart(playerid, params[])
{
	if(xo_info[i_trwa] == true)
		return SCM(playerid, -1, "Already one XO continues.");
	if(isnull(params)) return SCM(playerid, -1, "Use: /xostart <player id>");
	new player = strval(params);
	if(!IsPlayerConnected(player)) return SCM(playerid, -1, "Invalid player id.");
	if(player == playerid) return SCM(playerid, -1, "You can not play with yourself.");
	StartXO(playerid, player);
	return 1;
}

CMD:xo(playerid, params[])
{
	if(xo_info[i_trwa] == false) return SCM(playerid, -1, "It does''t take any XO.");
	if(xo_info[opo][0] != playerid && xo_info[opo][1] != playerid) return SCM(playerid, -1, "You do not take part in this game.");
	if(xo_info[opo][xo_info[ruch]] != playerid) return SCM(playerid, -1, "Now is move your opponent.");
	
	new pion, poziom;
	if(sscanf(params, "dd", pion, poziom))
		return SCM(playerid, -1, "U¿yj: /xo <column> <line>");
	
	if(pion < 0 || pion > 2 || poziom < 0 || poziom >2) return SCM(playerid, -1, "Bad value of one of the parameters.");
	SetOdpXO(playerid, pion, poziom);
	return 1;
}

stock StartXO(player1, player2)
{
	ClearXO();
	ShowXO(player1);
	ShowXO(player2);
	
	xo_info[opo][0] = player1;
	xo_info[opo][1] = player2;
	xo_info[i_trwa] = true;
	xo_info[zaznaczonych] = 0;
	xo_info[ruch] = random(2);
	
	xo_info[znaki][0] = XO_X;
	xo_info[znaki][1] = XO_O;
	
	new i_ruch = xo_info[ruch];
	
	xo_info[znaki][i_ruch] = XO_X;
	
	SCM(xo_info[opo][i_ruch], -1, "You start as a first. Use /xo <column> <line> to select.");
}

stock ClearXO()
{
	for(new i = 0; i < 3; i++)
	{
		for(new n = 0; n < 3; n++)
		{
			i_xo_plansza[i][n] = XO_NONE;
			TextDrawSetString(i_xo_a[i][n], " ");
		}
	}
}

stock SetOdpXO(playerid, pion, poziom)
{
	if(i_xo_plansza[pion][poziom] != XO_NONE) return SCM(playerid, -1, "Here is a character.");
	if(xo_info[ruch] == 0) xo_info[ruch] = 1;
	else xo_info[ruch] = 0;
	
	new xostring[512];
	if(playerid == xo_info[opo][0])
	{
		i_xo_plansza[pion][poziom] = XO_X;
		TextDrawSetString(i_xo_a[pion][poziom], "X");
		SCM(playerid, -1, "Your move... U¿yj: /xo <column> <line>");
		SCM(playerid, -1, "Your character is: O");
		if(SprawdzWygrana(XO_X))
		{
			// Wygrywa X
			format(xostring, sizeof(xostring), "XO win %s[%d].", Nick(playerid), playerid);
			SCMA(-1, xostring);
			EndXo();
		}
	}
	else
	{
		i_xo_plansza[pion][poziom] = XO_O;
		TextDrawSetString(i_xo_a[pion][poziom], "0");
		SCM(playerid, -1, "Your move... U¿yj: /xo <column> <line>");
		SCM(playerid, -1, "Your character is: X");
		if(SprawdzWygrana(XO_O))
		{
			// Wygrywa O
			format(xostring, sizeof(xostring), "XO win %s[%d].", Nick(playerid), playerid);
			SCMA(-1, xostring);
			EndXo();
		}
	}
	
	xo_info[zaznaczonych]++;
	if(xo_info[zaznaczonych] == 9)
	{
		// remis
		format(xostring, sizeof(xostring), "XO ended in a draw.", Nick(playerid), playerid);
		SCMA(-1, xostring);
		EndXo();
	}
	return 1;
}

stock EndXo()
{
	HideXO(xo_info[opo][0]);
	HideXO(xo_info[opo][1]);
	xo_info[i_trwa] = false;
	return 1;
}

stock SprawdzWygrana(znak)
{
	if(znak == XO_X)
	{
		// poziom
		if(i_xo_plansza[0][0] == XO_X && i_xo_plansza[0][1] == XO_X && i_xo_plansza[0][2] == XO_X) return 1;
		if(i_xo_plansza[1][0] == XO_X && i_xo_plansza[1][1] == XO_X && i_xo_plansza[1][2] == XO_X) return 1;
		if(i_xo_plansza[2][0] == XO_X && i_xo_plansza[2][1] && i_xo_plansza[2][2]) return 1;
		// pion
		if(i_xo_plansza[0][0] == XO_X && i_xo_plansza[1][0] == XO_X && i_xo_plansza[2][0] == XO_X) return 1;
		if(i_xo_plansza[0][1] == XO_X && i_xo_plansza[1][1] == XO_X && i_xo_plansza[2][1] == XO_X) return 1;
		if(i_xo_plansza[0][2] == XO_X && i_xo_plansza[1][2] == XO_X && i_xo_plansza[2][2] == XO_X) return 1;
		// skos
		if(i_xo_plansza[0][0] == XO_X && i_xo_plansza[1][1] == XO_X && i_xo_plansza[2][2] == XO_X) return 1;
		if(i_xo_plansza[0][2] == XO_X && i_xo_plansza[1][1] == XO_X && i_xo_plansza[2][0] == XO_X) return 1;
		
		return 0;
	}
	if(znak == XO_O)
	{
		// poziom
		if(i_xo_plansza[0][0] == XO_O && i_xo_plansza[0][1] == XO_O && i_xo_plansza[0][2] == XO_O) return 1;
		if(i_xo_plansza[1][0] == XO_O && i_xo_plansza[1][1] == XO_O && i_xo_plansza[1][2] == XO_O) return 1;
		if(i_xo_plansza[2][0] == XO_O && i_xo_plansza[2][1] && i_xo_plansza[2][2]) return 1;
		// pion
		if(i_xo_plansza[0][0] == XO_O && i_xo_plansza[1][0] == XO_O && i_xo_plansza[2][0] == XO_O) return 1;
		if(i_xo_plansza[0][1] == XO_O && i_xo_plansza[1][1] == XO_O && i_xo_plansza[2][1] == XO_O) return 1;
		if(i_xo_plansza[0][2] == XO_O && i_xo_plansza[1][2] == XO_O && i_xo_plansza[2][2] == XO_O) return 1;
		// skos
		if(i_xo_plansza[0][0] == XO_O && i_xo_plansza[1][1] == XO_O && i_xo_plansza[2][2] == XO_O) return 1;
		if(i_xo_plansza[0][2] == XO_O && i_xo_plansza[1][1] == XO_O && i_xo_plansza[2][0] == XO_O) return 1;
		
		return 0;
	}
	return 0;
}

stock ShowXO(playerid)
{
	for(new i = 0; i < 7; i++)
	{
		TextDrawShowForPlayer(playerid, i_xo[i]);
	}
	for(new i = 0; i < 3; i++)
	{
		for(new n = 0; n < 3; n++)
		{
			TextDrawShowForPlayer(playerid, i_xo_a[i][n]);
		}
	}
}

stock HideXO(playerid)
{
	for(new i = 0; i < 7; i++)
	{
		TextDrawHideForPlayer(playerid, i_xo[i]);
	}
	for(new i = 0; i < 3; i++)
	{
		for(new n = 0; n < 3; n++)
		{
			TextDrawHideForPlayer(playerid, i_xo_a[i][n]);
		}
	}
}

public OnFilterScriptExit()
{
	print("====================================\nXO by Inferno UNLOADED\nhttp://www.infus211.ct8.pl\n====================================");
	for(new i = 0; i < 7; i++)
	{
		TextDrawDestroy(i_xo[i]);
	}
	for(new i = 0; i < 3; i++)
	{
		for(new n = 0; n < 3; n++)
		{
			TextDrawDestroy(i_xo_a[i][n]);
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(xo_info[i_trwa])
	{
		new xostring[256];
		if(playerid == xo_info[opo][0])
		{
			// Wygrywa X
			format(xostring, sizeof(xostring), "XO win %s[%d].", Nick(xo_info[opo][1]), xo_info[opo][1]);
			SCMA(-1, xostring);
			EndXo();
		}
		if(playerid == xo_info[opo][1])
		{
			// Wygrywa X
			format(xostring, sizeof(xostring), "XO win %s[%d].", Nick(xo_info[opo][0]), xo_info[opo][0]);
			SCMA(-1, xostring);
			EndXo();
		}
	}
	return 1;
}

public OnFilterScriptInit()
{
	print("====================================\nXO by Inferno LOADED\nhttp://www.infus211.ct8.pl\n====================================");
	xo_info[i_trwa] = false;
	xo_info[opo][0] = -1;
	xo_info[opo][1] = -1;

	i_xo[0] = TextDrawCreate(423.500000, 143.833343, "usebox");
	TextDrawLetterSize(i_xo[0], 0.000000, 22.887039);
	TextDrawTextSize(i_xo[0], 215.000000, 0.000000);
	TextDrawAlignment(i_xo[0], 1);
	TextDrawColor(i_xo[0], 0);
	TextDrawUseBox(i_xo[0], true);
	TextDrawBoxColor(i_xo[0], 102);
	TextDrawSetShadow(i_xo[0], 0);
	TextDrawSetOutline(i_xo[0], 0);
	TextDrawFont(i_xo[0], 0);

	i_xo[1] = TextDrawCreate(283.700012, 144.591659, "usebox");
	TextDrawLetterSize(i_xo[1], 0.000000, 22.782226);
	TextDrawTextSize(i_xo[1], 278.400024, 0.000000);
	TextDrawAlignment(i_xo[1], 1);
	TextDrawColor(i_xo[1], 0);
	TextDrawUseBox(i_xo[1], true);
	TextDrawBoxColor(i_xo[1], 102);
	TextDrawSetShadow(i_xo[1], 0);
	TextDrawSetOutline(i_xo[1], 0);
	TextDrawFont(i_xo[1], 0);

	i_xo[2] = TextDrawCreate(355.250030, 143.833343, "usebox");
	TextDrawLetterSize(i_xo[2], 0.000000, 22.847417);
	TextDrawTextSize(i_xo[2], 350.000000, 0.000000);
	TextDrawAlignment(i_xo[2], 1);
	TextDrawColor(i_xo[2], 0);
	TextDrawUseBox(i_xo[2], true);
	TextDrawBoxColor(i_xo[2], 102);
	TextDrawSetShadow(i_xo[2], 0);
	TextDrawSetOutline(i_xo[2], 0);
	TextDrawFont(i_xo[2], 0);

	i_xo[3] = TextDrawCreate(423.250030, 211.966751, "usebox");
	TextDrawLetterSize(i_xo[3], 0.000000, -0.316666);
	TextDrawTextSize(i_xo[3], 214.749984, 0.000000);
	TextDrawAlignment(i_xo[3], 1);
	TextDrawColor(i_xo[3], 0);
	TextDrawUseBox(i_xo[3], true);
	TextDrawBoxColor(i_xo[3], 102);
	TextDrawSetShadow(i_xo[3], 0);
	TextDrawSetOutline(i_xo[3], 0);
	TextDrawFont(i_xo[3], 0);

	i_xo[4] = TextDrawCreate(423.500000, 283.250000, "usebox");
	TextDrawLetterSize(i_xo[4], 0.000000, -0.316666);
	TextDrawTextSize(i_xo[4], 215.000000, 0.000000);
	TextDrawAlignment(i_xo[4], 1);
	TextDrawColor(i_xo[4], 0);
	TextDrawUseBox(i_xo[4], true);
	TextDrawBoxColor(i_xo[4], 102);
	TextDrawSetShadow(i_xo[4], 0);
	TextDrawSetOutline(i_xo[4], 0);
	TextDrawFont(i_xo[4], 0);
	
	i_xo[5] = TextDrawCreate(243.500000, 113.166687, "0      1      2");
	TextDrawLetterSize(i_xo[5], 0.571000, 2.387503);
	TextDrawAlignment(i_xo[5], 1);
	TextDrawColor(i_xo[5], -1);
	TextDrawSetShadow(i_xo[5], 0);
	TextDrawSetOutline(i_xo[5], 1);
	TextDrawBackgroundColor(i_xo[5], 51);
	TextDrawFont(i_xo[5], 1);
	TextDrawSetProportional(i_xo[5], 1);

	i_xo[6] = TextDrawCreate(196.000000, 160.416671, "0~n~~n~~n~1~n~~n~~n~2");
	TextDrawLetterSize(i_xo[6], 0.553000, 2.673336);
	TextDrawAlignment(i_xo[6], 1);
	TextDrawColor(i_xo[6], -1);
	TextDrawSetShadow(i_xo[6], 0);
	TextDrawSetOutline(i_xo[6], 1);
	TextDrawBackgroundColor(i_xo[6], 51);
	TextDrawFont(i_xo[6], 1);
	TextDrawSetProportional(i_xo[6], 1);
	

	i_xo_a[0][0] = TextDrawCreate(249.000000, 147.000015, "X");
	TextDrawLetterSize(i_xo_a[0][0], 1.661900, 5.927165);
	TextDrawAlignment(i_xo_a[0][0], 2);
	TextDrawColor(i_xo_a[0][0], -1);
	TextDrawSetShadow(i_xo_a[0][0], 0);
	TextDrawSetOutline(i_xo_a[0][0], 1);
	TextDrawBackgroundColor(i_xo_a[0][0], 51);
	TextDrawFont(i_xo_a[0][0], 1);
	TextDrawSetProportional(i_xo_a[0][0], 1);

	i_xo_a[0][1] = TextDrawCreate(318.500000, 145.833358, "X");
	TextDrawLetterSize(i_xo_a[0][1], 1.688150, 6.128999);
	TextDrawAlignment(i_xo_a[0][1], 2);
	TextDrawColor(i_xo_a[0][1], -1);
	TextDrawSetShadow(i_xo_a[0][1], 0);
	TextDrawSetOutline(i_xo_a[0][1], 1);
	TextDrawBackgroundColor(i_xo_a[0][1], 51);
	TextDrawFont(i_xo_a[0][1], 1);
	TextDrawSetProportional(i_xo_a[0][1], 1);

	i_xo_a[0][2] = TextDrawCreate(365.750000, 144.024993, "X");
	TextDrawLetterSize(i_xo_a[0][2], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[0][2], 1);
	TextDrawColor(i_xo_a[0][2], -1);
	TextDrawSetShadow(i_xo_a[0][2], 0);
	TextDrawSetOutline(i_xo_a[0][2], 1);
	TextDrawBackgroundColor(i_xo_a[0][2], 51);
	TextDrawFont(i_xo_a[0][2], 1);
	TextDrawSetProportional(i_xo_a[0][2], 1);

	i_xo_a[1][0] = TextDrawCreate(228.250000, 213.441680, "X");
	TextDrawLetterSize(i_xo_a[1][0], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[1][0], 1);
	TextDrawColor(i_xo_a[1][0], -1);
	TextDrawSetShadow(i_xo_a[1][0], 0);
	TextDrawSetOutline(i_xo_a[1][0], 1);
	TextDrawBackgroundColor(i_xo_a[1][0], 51);
	TextDrawFont(i_xo_a[1][0], 1);
	TextDrawSetProportional(i_xo_a[1][0], 1);

	i_xo_a[1][1] = TextDrawCreate(296.250000, 212.858230, "X");
	TextDrawLetterSize(i_xo_a[1][1], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[1][1], 1);
	TextDrawColor(i_xo_a[1][1], -1);
	TextDrawSetShadow(i_xo_a[1][1], 0);
	TextDrawSetOutline(i_xo_a[1][1], 1);
	TextDrawBackgroundColor(i_xo_a[1][1], 51);
	TextDrawFont(i_xo_a[1][1], 1);
	TextDrawSetProportional(i_xo_a[1][1], 1);

	i_xo_a[1][2] = TextDrawCreate(365.250000, 212.274993, "X");
	TextDrawLetterSize(i_xo_a[1][2], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[1][2], 1);
	TextDrawColor(i_xo_a[1][2], -1);
	TextDrawSetShadow(i_xo_a[1][2], 0);
	TextDrawSetOutline(i_xo_a[1][2], 1);
	TextDrawBackgroundColor(i_xo_a[1][2], 51);
	TextDrawFont(i_xo_a[1][2], 1);
	TextDrawSetProportional(i_xo_a[1][2], 1);

	i_xo_a[2][0] = TextDrawCreate(225.750000, 284.608306, "X");
	TextDrawLetterSize(i_xo_a[2][0], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[2][0], 1);
	TextDrawColor(i_xo_a[2][0], -1);
	TextDrawSetShadow(i_xo_a[2][0], 0);
	TextDrawSetOutline(i_xo_a[2][0], 1);
	TextDrawBackgroundColor(i_xo_a[2][0], 51);
	TextDrawFont(i_xo_a[2][0], 1);
	TextDrawSetProportional(i_xo_a[2][0], 1);

	i_xo_a[2][1] = TextDrawCreate(295.750000, 285.191711, "X");
	TextDrawLetterSize(i_xo_a[2][1], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[2][1], 1);
	TextDrawColor(i_xo_a[2][1], -1);
	TextDrawSetShadow(i_xo_a[2][1], 0);
	TextDrawSetOutline(i_xo_a[2][1], 1);
	TextDrawBackgroundColor(i_xo_a[2][1], 51);
	TextDrawFont(i_xo_a[2][1], 1);
	TextDrawSetProportional(i_xo_a[2][1], 1);

	i_xo_a[2][2] = TextDrawCreate(365.250000, 284.025054, "X");
	TextDrawLetterSize(i_xo_a[2][2], 1.807499, 6.616664);
	TextDrawAlignment(i_xo_a[2][2], 1);
	TextDrawColor(i_xo_a[2][2], -1);
	TextDrawSetShadow(i_xo_a[2][2], 0);
	TextDrawSetOutline(i_xo_a[2][2], 1);
	TextDrawBackgroundColor(i_xo_a[2][2], 51);
	TextDrawFont(i_xo_a[2][2], 1);
	TextDrawSetProportional(i_xo_a[2][2], 1);
	return 1;
}

Nick(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}