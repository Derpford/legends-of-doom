class LegendHud : BaseStatusBar {
    HUDFont mConFont;
	HUDFont mStatFont;
	HUDFont mDetailFont;

	double invticfrac; // controls animating invbar items

	override void Init()
	{
		Super.Init();
		SetSize(0,320,240);

		mConFont = HUDFont.Create("CONFONT",0,false,1,1);
		mDetailFont = HUDFont.Create("SMALLFONT",0,false,1,1);
		mStatFont = HUDFont.Create("DBIGFONT",0,false,1,1);
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
		// Monster XP goes in upper right.
        int monbarflags = DI_SCREEN_RIGHT_TOP|DI_ITEM_RIGHT_TOP;
		int montxtflags = DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT;

		if(plr)
		{
			int hp = CPlayer.Health;
			int maxhp = plr.GetMaxHealth(true);
			int arm = plr.CountInv("LegendArmor");
			int lvl = plr.level;
			double xp = plr.xp;
			double xpmax = plr.MaxXP();
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
            DrawImage("HPAKB0",(12,-20),lbarflags);
			if (arm > 0) { 
				// Armor goes below the health string.
				if (arm > maxhp) {
					DrawImage("ARM2A0",(80,-8),lbarflags); 
				} else {
					DrawImage("ARM1A0",(80,-8),lbarflags); 
				}
                DrawString(mStatFont,arm.."/"..maxhp,(100,-20),ltxtflags,Font.CR_CYAN);
			}
            DrawString(mStatFont,hp.."/"..maxhp,(32,-32),ltxtflags,Font.CR_BRICK);

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
            vector2 ammo1Pos = (-80,-4);
			vector2 ammo2Pos = (-12,-12);
			vector2 ammoText1Pos = (ammo1Pos.x-40,ammo1pos.y-16);
			vector2 ammoText2Pos = (ammo2Pos.x-40,ammo2Pos.y-16);
			if (wpn) {
				let a1 = wpn.AmmoType1;
				let a2 = wpn.AmmoType2;
				if(a1 && wpn.ammouse1 > 0)
				{
					let a1real = plr.FindInventory(a1.GetClassName());// a1 is a ClassPointer<Ammo>, a1real is a Pointer<Inventory>
					//DrawImage("CLIPA0",(ammoXpos,-2),rbarflags,scale:(2,2));
					DrawInventoryIcon(a1real,ammo1pos,rbarflags,scale:(2,2));
					double amt = GetAmount(a1.GetClassName());
					double used = wpn.ammouse1;
					int shots = floor(amt / used);
					DrawString(mStatFont,FormatNumber(shots), ammoText1Pos,rtxtflags,Font.CR_RED);
				}

				if (a2 && a2 != a1 && wpn.ammouse2 > 0) {
					let a2real = plr.FindInventory(a2.GetClassName());
					DrawInventoryIcon(a2real,ammo2Pos,rbarflags,scale:(2,2));
					double amt = GetAmount(a2.GetClassName());
					double used = wpn.ammouse2;
					int shots = floor(amt / used);
					DrawString(mStatFont,FormatNumber(shots), ammoText2Pos,rtxtflags,Font.CR_RED);
				}
			}

			int ammoBarXPos = -24;

			for (int i = 0; i < 5; i++) {
				int amt, cap;
				[amt, cap] = GetAmount(ammoTypes[i]);
				Vector2 pos = (8 + ammoBarXPos - (9 * i),-48);
				if (amt == cap && (plr.GetAge() % 10 > 5)) { 
					DrawImage(ammoBars[i].."A0",pos,rbarflags); // Ammo bars flash when full!
				} else {
					DrawBar(ammoBars[i].."B0",ammoBars[i].."A0",amt,cap,pos,2,SHADER_VERT,rbarflags);
				}
			}

			// Monster level.
			int monlvlpos = -24;
			int monXPos = -68;
            int monYPos = 24;
			let monsterhandler = MonsterLevelHandler(EventHandler.Find("MonsterLevelHandler"));
			if (monsterhandler.brain) {
				int mlvl = monsterhandler.brain.monsterlevel;
				double mxp = monsterhandler.brain.monsterxp;
				DrawString(mConFont,String.Format("Monster Level:"),(monXPos,monYPos),montxtflags,Font.CR_RED);
				DrawString(mStatFont,String.Format("%03d",mlvl+1),(monlvlpos,monYPos),montxtflags,Font.CR_RED,scale:(1.5,1.5));
				DrawBar("MBARB0","MBARA0",mxp,150,(monXPos,monYPos+10),2,0,monbarflags);
				// DrawString(mConFont,String.Format("(%0.1f%%)",100 * (mxp / 150.)),(monXPos,monYPos+9),montxtflags,Font.CR_RED);
			}

			// The XP bar.
			DrawBar("XBARB0","XBARA0",xp,xpmax,(0,-08),2,SHADER_REVERSE,cbarflags);
			// Level.
			DrawImage("SLVL",(72,-8),cbarflags);
			DrawString(mStatFont,String.Format("%d",lvl+1),(80,-16),ctxtflags,Font.CR_WHITE);
			// Inventory icon.
			let w = plr.InvSel;
			if (w) {
				vector2 invpos = (-96,-8);
				if (IsInventoryBarVisible()) {
					invticfrac = clamp(invticfrac+0.5,0,4);
				} else {
					invticfrac = clamp(invticfrac-0.5,0,4);
				}
				if (w.PrevInv()) {
					DrawInventoryIcon(w.PrevInv(),invpos+(-16,-2),cbarflags,0.5);
				}
				if (w.NextInv()) {
					DrawInventoryIcon(w.NextInv(),invpos+(16,-2),cbarflags,0.5);
				}

				DrawInventoryIcon(w,invpos+(0,-invticfrac),cbarflags);
			}

            // Finally, the stats.
            int statXPos = 16;
            int statTextXPos = statXPos+8;
			int statYPos = -56;
			// Luck.
			DrawImage("SLUK",(statXPos,statYPos),statbarflags);
            DrawString(mStatFont,String.Format("%.2f",luck),(statTextXPos,statYPos-8),stattxtflags,Font.CR_GREEN);
			statYPos -= 18;
			// Toughness.
			DrawImage("STUF",(statXPos,statYPos),statbarflags);
            DrawString(mStatFont,String.Format("%.2f",toughness),(statTextXPos,statYPos-8),stattxtflags,Font.CR_BLUE);
			statYPos -= 18;
			// Precision.
			DrawImage("SPRC",(statXPos,statYPos),statbarflags);
            DrawString(mStatFont,String.Format("%.2f",precision),(statTextXPos,statYPos-8),stattxtflags,Font.CR_PURPLE);
			statYPos -= 18;
			// Power.
			DrawImage("SPOW",(statXPos,statYPos),statbarflags);
            DrawString(mStatFont,String.Format("%.2f",power),(statTextXPos,statYPos-8),stattxtflags,Font.CR_ORANGE);

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