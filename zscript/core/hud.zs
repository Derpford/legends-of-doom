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
        // Statbar goes in upper left.
        int statbarflags = DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP;
        int stattxtflags = DI_SCREEN_LEFT_TOP|DI_TEXT_ALIGN_LEFT;

		if(plr)
		{
			int hp = CPlayer.Health;
			int maxhp = plr.GetMaxHealth();
			int arm = GetAmount("BasicArmor");
            double power = plr.GetPower(true);
            double precision = plr.GetPrecision();
            double toughness = plr.GetToughness();
            double luck = plr.GetLuck();
            let wpn = CPlayer.ReadyWeapon;

            // Start with health.
            DrawImage("MEDIA0",(12,-2),lbarflags);
            DrawString(mStatFont,hp.."/"..maxhp,(32,-28),ltxtflags,Font.CR_BRICK);

            // Next, ammo.
            // TODO: Bars for the four ammo types.
            int ammoXPos = -24;
			int ammoTextXPos = ammoXPos-32;
			let a1 = wpn.AmmoType1;
			if(a1)
			{
				let a1real = plr.FindInventory(a1.GetClassName());// a1 is a ClassPointer<Ammo>, a1real is a Pointer<Inventory>
				//DrawImage("CLIPA0",(ammoXpos,-2),rbarflags,scale:(2,2));
				DrawInventoryIcon(a1real,(ammoXPos,-2),rbarflags,scale:(2,2));
				DrawString(mStatFont,FormatNumber(GetAmount(a1.GetClassName())), (ammoTextXPos,-24),rtxtflags,Font.CR_RED);
			}

            // Finally, the stats.
            int statXPos = 24;
            int statTextXPos = statXPos+8;
            DrawString(mConFont,"POW: "..String.Format("%.2f",power),(statTextXPos,64),stattxtflags);
            DrawString(mConFont,"PRC: "..String.Format("%.2f",precision),(statTextXPos,64+8),stattxtflags);
            DrawString(mConFont,"TUF: "..String.Format("%.2f",toughness),(statTextXPos,64+16),stattxtflags);
            DrawString(mConFont,"LUK: "..String.Format("%.2f",luck),(statTextXPos,64+24),stattxtflags);
        }
    }
}