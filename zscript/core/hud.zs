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
			double xpperc = 100. * (xp / xpmax);
            double power = plr.UI_GetPower(true);
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
			Name ammoTypes[4] = {
				"GreenAmmo",
				"RedAmmo",
				"YellowAmmo",
				"BlueAmmo"
			};
			String ammoBars[4] = {
				"GBAR",
				"RBAR",
				"YBAR",
				"BBAR"
			};
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

			for (int i = 0; i < 4; i++) {
				int amt, cap;
				[amt, cap] = GetAmount(ammoTypes[i]);
				DrawBar(ammoBars[i].."B0",ammoBars[i].."A0",amt,cap,(ammoXPos,-36 - (9 * i)),2,0,rbarflags);
			}

            // Finally, the stats.
            int statXPos = 16;
            int statTextXPos = statXPos+8;
            int statYPos = 36;
			// Level.
			DrawImage("SLVL",(statXPos,statYPos),statbarflags);
			DrawString(mConFont,String.Format("%d (%.1f%%)",lvl,xpperc),(statTextXPos,statYPos),stattxtflags,Font.CR_WHITE);
			statYPos += 9;
			// Power.
			DrawImage("SPOW",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",power),(statTextXPos,statYPos),stattxtflags,Font.CR_ORANGE);
			statYPos += 9;
			// Precision.
			DrawImage("SPRC",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",precision),(statTextXPos,statYPos),stattxtflags,Font.CR_PURPLE);
			statYPos += 9;
			// Toughness.
			DrawImage("STUF",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",toughness),(statTextXPos,statYPos),stattxtflags,Font.CR_BLUE);
			statYPos += 9;
			// Luck.
			DrawImage("SLUK",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",luck),(statTextXPos,statYPos),stattxtflags,Font.CR_GREEN);

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