class LegendHud : BaseStatusBar {
    HUDFont mConFont;
	HUDFont mStatFont;
	override void Init()
	{
		Super.Init();
		SetSize(0,320,240);

		mConFont = HUDFont.Create("CONFONT");
		mStatFont = HUDFont.Create("DBIGFONT");
	}	

	override void Draw(int state, double ticfrac)
	{
		Super.Draw(state, ticfrac);

		BeginHUD();
		DrawFullscreenStuff();
		// Non-fullscreen bar later.
	}

	void DrawFullscreenStuff()
	{
		let plr = LegendPlayer(CPlayer.mo);

        // Bottom of screen stuff.
		int lbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM;
		int rbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM;
		int ltxtflags = DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
		int rtxtflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;
		int cbarflags = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
        // Statbar goes in upper left.
        int statbarflags = DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP;
        int stattxtflags = DI_SCREEN_LEFT_TOP|DI_TEXT_ALIGN_LEFT;

		if(plr)
		{
			int hp = CPlayer.Health;
			int maxhp = plr.GetMaxHealth(true);
			int arm = GetAmount("BasicArmor");
			int lvl = plr.level;
			double xp = plr.xp;
			double xpmax = plr.level * 100.;
			double xpperc = xp / xpmax;
            double power = plr.GetPower(true);
            double precision = plr.GetPrecision();
            double toughness = plr.GetToughness();
            double luck = plr.GetLuck();
            let wpn = CPlayer.ReadyWeapon;

            // Start with health.
            DrawImage("MEDIA0",(24,-2),lbarflags);
            DrawString(mStatFont,hp.."/"..maxhp,(32,-28),ltxtflags,Font.CR_BRICK);

            // And the armor!
            if (arm > 0) {
                DrawImage("ARM1A0",(24,-34),lbarflags);
                DrawString(mStatFont,arm.."/200",(32,-42),ltxtflags,Font.CR_CYAN);
            }

            // Next, ammo.
            // TODO: Bars for the four ammo types.
            int ammoXPos = -24;
			int ammoTextXPos = ammoXPos-32;
			if (wpn) {
				let a1 = wpn.AmmoType1;
				if(a1)
				{
					let a1real = plr.FindInventory(a1.GetClassName());// a1 is a ClassPointer<Ammo>, a1real is a Pointer<Inventory>
					//DrawImage("CLIPA0",(ammoXpos,-2),rbarflags,scale:(2,2));
					DrawInventoryIcon(a1real,(ammoXPos,-2),rbarflags,scale:(2,2));
					DrawString(mStatFont,FormatNumber(GetAmount(a1.GetClassName())).."/"..a1real.maxamount, (ammoTextXPos,-24),rtxtflags,Font.CR_RED);
				}
			}

            // Finally, the stats.
            int statXPos = 8;
            int statTextXPos = statXPos+16;
            int statYPos = 36;
			DrawString(mConFont,"LVL: "..String.Format("%d",lvl)..", "..String.Format("%.1f%%",xpperc),(statTextXPos,statYPos),stattxtflags,Font.CR_WHITE);
            DrawString(mConFont,"POW: "..String.Format("%.2f",power),(statTextXPos,statYPos+8),stattxtflags,Font.CR_ORANGE);
            DrawString(mConFont,"PRC: "..String.Format("%.2f",precision),(statTextXPos,statYPos+16),stattxtflags,Font.CR_PURPLE);
            DrawString(mConFont,"TUF: "..String.Format("%.2f",toughness),(statTextXPos,statYPos+24),stattxtflags,Font.CR_BLUE);
            DrawString(mConFont,"LUK: "..String.Format("%.2f",luck),(statTextXPos,statYPos+32),stattxtflags,Font.CR_GREEN);

			// Don't forget keys!
			String keySprites[6] =
			{
				"STKEYS2",
				"STKEYS0",
				"STKEYS1",
				"STKEYS5",
				"STKEYS3",
				"STKEYS4"
			};

			for(int i = 0; i < 6; i++)
			{
				if(plr.CheckKeys(i+1,false,true)) { DrawImage(keySprites[i],(-40+(16*i),-8),cbarflags,scale:(2,2)); }
			}
        }
    }
}