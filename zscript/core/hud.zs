class LegendHud : BaseStatusBar {
    HUDFont mConFont;
	HUDFont mStatFont;
	HUDFont mDetailFont;
	override void Init()
	{
		Super.Init();
		SetSize(0,320,240);

		mConFont = HUDFont.Create("CONFONT");
		mDetailFont = HUDFont.Create("SMALLFONT");
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
		int ctxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_LEFT;
		int crtxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT;
        // Statbar goes in upper left.
        int statbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM;
        int stattxtflags = DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;

		if(plr)
		{
			int hp = CPlayer.Health;
			int maxhp = plr.GetMaxHealth(true);
			int arm = GetAmount("BasicArmor");
			int lvl = plr.level;
			double xp = plr.xp;
			double xpmax = (plr.level+1) * 100.;
			double xpperc = 100. * (xp / xpmax);
            double power = plr.UI_GetPower(true);
            double precision = plr.GetPrecision();
            double toughness = plr.GetToughness();
            double luck = plr.GetLuck();
            let wpn = CPlayer.ReadyWeapon;
			LegendItem itm;
			int itms = plr.recentItems.size();
			if (itms > 0) { itm = plr.recentItems[0]; }

            // Start with health.
            DrawImage("MEDIA0",(24,-2),lbarflags);
            DrawString(mStatFont,hp.."/"..maxhp,(32,-28),ltxtflags,Font.CR_BRICK);

            // And the armor!
            if (arm > 0) {
                DrawImage("ARM1A0",(24,-34),lbarflags);
                DrawString(mStatFont,arm.."/200",(32,-42),ltxtflags,Font.CR_CYAN);
            }

            // Next, ammo.
			Name ammoTypes[5] = {
				"GreenAmmo",
				"RedAmmo",
				"YellowAmmo",
				"BlueAmmo",
				"PinkAmmo"
			};
			String ammoBars[5] = {
				"GBAR",
				"RBAR",
				"YBAR",
				"BBAR",
				"PBAR"
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

			for (int i = 0; i < 5; i++) {
				int amt, cap;
				[amt, cap] = GetAmount(ammoTypes[i]);
				Vector2 pos = (8 + ammoXPos - (9 * i),-48);
				if (amt == cap && (plr.GetAge() % 10 > 5)) { 
					DrawImage(ammoBars[i].."A0",pos,rbarflags); // Ammo bars flash when full!
				} else {
					DrawBar(ammoBars[i].."B0",ammoBars[i].."A0",amt,cap,pos,2,SHADER_VERT,rbarflags);
				}
			}

			// The XP bar.
			DrawBar("XBARB0","XBARA0",xp,xpmax,(0,-08),2,SHADER_REVERSE,cbarflags);

            // Finally, the stats.
            int statXPos = 16;
            int statTextXPos = statXPos+8;
            int statYPos = -56;
			// Monster level.
			let monsterhandler = MonsterLevelHandler(EventHandler.Find("MonsterLevelHandler"));
			if (monsterhandler.brain) {
				int mlvl = monsterhandler.brain.monsterlevel;
				DrawString(mConFont,String.Format("Monster LVL: %d",mlvl+1),(statTextXPos,statYPos-8),stattxtflags,Font.CR_WHITE);
			}
			statYPos -= 9;
			// Luck.
			DrawImage("SLUK",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",luck),(statTextXPos,statYPos-8),stattxtflags,Font.CR_GREEN);
			statYPos -= 9;
			// Toughness.
			DrawImage("STUF",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",toughness),(statTextXPos,statYPos-8),stattxtflags,Font.CR_BLUE);
			statYPos -= 9;
			// Precision.
			DrawImage("SPRC",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",precision),(statTextXPos,statYPos-8),stattxtflags,Font.CR_PURPLE);
			statYPos -= 9;
			// Power.
			DrawImage("SPOW",(statXPos,statYPos),statbarflags);
            DrawString(mConFont,String.Format("%.2f",power),(statTextXPos,statYPos-8),stattxtflags,Font.CR_ORANGE);
			statYPos -= 9;
			// Level.
			DrawImage("SLVL",(statXPos,statYPos),statbarflags);
			DrawString(mConFont,String.Format("%d",lvl+1),(statTextXPos,statYPos-8),stattxtflags,Font.CR_WHITE);

			// If there's an item in the recentItems array, display it.
			if (itm) {
				string nm = itm.GetTag();
				BrokenLines desc = Smallfont.BreakLines(itm.GetShortDesc(),200);
				string remark = itm.GetRemark();
				double time = plr.itemTimer / 5.;
				int remaining = 160 - floor(160. * time);
				// BG.
				Fill(Color(128,0,0,0), -80,-64,200,40,cbarflags);
				// Icon BG.
				Fill(Color(192,0,0,0),-120,-64,40,40,cbarflags);
				// Time remaining before next item.
				Fill(Color(255,255,255,255),-80,-24,remaining,2,cbarflags);
				// The icon.
				DrawImage(itm.invicon,(-100,-24),cbarflags,scale:itm.scale);
				// Details.
				DrawString(mDetailFont,nm,(-80,-64),ctxtflags,Font.CR_RED);
				DrawString(mDetailFont,remark,(-80,-56),ctxtflags,Font.CR_DARKGRAY);
				for (int i = 0; i < desc.Count(); i++) {
					DrawString(mDetailFont,desc.StringAt(i),(-80,-48+(8 * i)),ctxtflags,Font.CR_WHITE);
				}
				if (itms > 1)
				DrawString(mDetailFont,String.Format("%d...",itms),(120,-40),ctxtflags,Font.CR_DARKGRAY,scale:(2,2));
			}

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
				if(plr.CheckKeys(i+1,false,true)) { 
					if(i < 3) {
						DrawImage(keySprites[i],(-44-(8*i),-9),cbarflags,scale:(1,1)); 
					} else {
						DrawImage(keySprites[i],(44+(8*(i-3)),-9),cbarflags,scale:(1,1)); 
					}
				}
			}
        }
    }
}