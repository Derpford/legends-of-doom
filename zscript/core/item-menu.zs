class ItemMenu : LegendZFGenericMenu {
    // Shows all your items, along with tooltips.
    ItemMenuHandler handler;
    Font fnt;
    Font bigfnt; // for names, etc
    PlayerPawn plr;
    int namecolor;
    int remarkcolor;
    int basecolor; // Used for all non-Name, non-Remark text
    Color bgcolor; // The frame fill.
    Color frcolor; // The outline.

    Vector2 baseres; 

    Vector2 bgpos;
    Vector2 bgsize;

    int listborder;
    Vector2 listpos;
    Vector2 listsize;

    bool displayLongDesc;
    Vector2 longdescpos;
    Vector2 longdescsize;
    Vector2 longbgpos;
    Vector2 longbgsize;

    bool displayTooltip;
    bool updateTooltip;
    Vector2 tooltippos;
    Vector2 tooltipsize;
    Vector2 tooltipoffset;

    LegendZFFrame tooltip;
    LegendZFLabel ttname;
    LegendZFLabel ttremark;
    LegendZFLabel ttdesc;

    String title;
    int iid;
    String iname;
    String remark;
    String shortdesc;
    String longdesc;

    Array<LegendItem> items;

    override void Init (Menu parent) {
        Super.init(parent);

        baseres = (640,480);
        setBaseResolution(baseres);
        iid = -1;
        iname = "Placeholder";
        remark = "This is a test.";
        shortdesc = "A short description.";

        handler = new ('ItemMenuHandler');
        handler.link = self;

        let plr = players[consoleplayer].mo;

        title = "Item List";

        let btex = LegendZFBoxTextures.CreateTexturePixels (
            "graphics/BBOX.png",
            (2,2),
            (6,6),
            false,
            false
        );

        let btex2 = LegendZFBoxTextures.CreateTexturePixels (
            "graphics/BBOX2.png",
            (2,2),
            (6,6),
            false,
            false
        );


        int padding = 4;
        bgpos = (padding/2,padding/2);
        bgsize = (baseres.x-padding,baseres.y-padding);

        fnt = Font.GetFont("SMALLFONT");
        bigfnt = Font.GetFont("DBIGFONT");

        namecolor = Font.CR_RED;
        remarkcolor = Font.CR_DARKGRAY;
        basecolor = Font.CR_WHITE;
        
        listborder = 2;
        int topborder = 16;
        listpos = (bgpos.x+listborder,bgpos.y+listborder+bigfnt.GetHeight()+topborder);
        listsize = (bgsize.x - listborder,bgsize.y - listborder); // 2px border :D

        let itm = plr.inv;
        while (itm) {
            let lit = LegendItem(itm);
            if (lit) {
                items.push(lit);
            } 
            itm = itm.inv;
        }

        let bg = LegendZFBoxImage.Create (
            bgpos,
            bgsize,
            btex,
            (1,1)
        );

        bg.pack(mainFrame);

        LegendZFLabel.Create (
            (1,1),
            (200,bigfnt.GetHeight()),
            text: "Items",
            fnt: bigfnt,
            wrap: false,
            autosize: true,
            textColor: namecolor
        ).pack(mainFrame); // We don't need to change this label.

        LegendZFLabel.Create (
            (1,1+bigfnt.GetHeight()),
            (200,fnt.GetHeight()),
            text: "Click to toggle description",
            fnt: fnt,
            wrap: false,
            autosize:true,
            textColor: basecolor
        ).pack(mainFrame); // Or this one.

        // titleLabel.pack(mainFrame);

        for (int i = 0; i < items.size(); i++) {
            let tx = LegendZFBoxTextures.CreateSingleTexture(items[i].invicon, true);
            let size = mainFrame.texSize(items[i].invicon);
            let stacks = items[i].GetStacks();

            let xslots = floor(bgsize.x/64.); // How many items wide is this list?
            int xsp = i % xslots; 
            let lposx = listpos.x + (xsp * 64);
            int ysp = i / xslots;
            let lposy = listpos.y + (ysp * 64);
            let pos = (lposx,lposy); // TODO: Wrapping
            let offs = (32 - (size.x * 0.5), 32 - (size.y * 0.5));
            let ibtn = LegendZFButton.Create (
                pos, // TODO: Wrapping
                (64,64),
                cmdHandler: handler,
                command: String.format("%d",i),
                inactive: btex,
                hover: btex,
                click: btex
            );
            ibtn.pack(mainFrame);
            LegendZFBoxImage.Create(pos+offs,size,tx,(1,1)).pack(mainFrame); // add the item icon in the center of the slot.
            LegendZFLabel.Create(pos+(48,48),(64,64),text:String.Format("%d",stacks),autosize:true).pack(mainFrame); // And the slot number.
            
        }

        // Build a tooltip!
        tooltippos = (1,1);
        tooltipsize = (201,49);
        tooltipoffset = (20,20);
        displayTooltip = false;
        let fheight = fnt.GetHeight();

        tooltip = LegendZFFrame.Create(
            tooltippos,
            tooltipsize
        );
        tooltip.pack(mainFrame);
        // Background...
        let ttbg = LegendZFBoxImage.Create (
            (0,0),
            tooltipSize - (1,1),
            btex2,
            (1,1)
        ); 
        ttbg.pack(tooltip);

        // Item name...
        ttname = LegendZFLabel.Create (
            (1,1),
            tooltipSize - (2,2),
            text: iname,
            fnt: fnt,
            wrap: false,
            autosize:true,
            textColor:namecolor
        ); 
        ttname.pack(tooltip);

        // Item remark...
        ttremark = LegendZFLabel.Create (
            (1,10),
            tooltipSize - (2,2),
            text: remark,
            fnt: fnt,
            wrap: false,
            autosize:true,
            textColor:remarkcolor
        );
        ttremark.pack(tooltip);

        // Item description...
        ttdesc = LegendZFLabel.Create(
            (1,19),
            tooltipSize - (2,2),
            text: shortdesc,
            fnt: fnt,
            wrap: true,
            textColor:basecolor
        ); 
        ttdesc.pack(tooltip);

    }

    override void Ticker() {
        tooltip.hidden = !displayTooltip;
        // tooltipPos = mainFrame.screenToRel((mouseX,mouseY) + tooltipoffset);
        if (iid > -1 && items.Size() > iid) {
            iname = items[iid].GetTag();
            remark = items[iid].GetRemark();
            shortdesc = items[iid].GetShortDesc();
        }
        tooltip.setBox(tooltipPos,tooltipSize);
        ttname.text = iname;
        ttdesc.text = shortdesc;
        ttremark.text = remark;
    }
}

class ItemMenuHandler : LegendZFHandler {
    ItemMenu link;

    // override void ElementHoverChanged(LegendZFElement caller, string cmd, bool unhover) {
    //     let l = ItemMenu(link);
    //     console.printf("Hover state: "..unhover);
    //     console.printf("Hover command: "..cmd);
    //     if (unhover) {
    //         l.iid = -1;
    //     } else {
    //         console.printf("hovered "..cmd);
    //         int idx = cmd.toInt();
    //         l.iid = idx;
    //     }
    // }
    override void buttonClickCommand(LegendZFButton caller, string cmd) {
        int idx = cmd.toInt();
        if (idx == link.iid) {
            link.displayTooltip = !link.displayTooltip;
        } else {
            link.displayTooltip = true;
            link.iid = idx;
            let ts = link.tooltipSize;
            let posx = clamp(2, link.baseres.x - ts.x - 4,caller.box.pos.x);
            let posy = clamp(2,link.baseres.y - ts.y - 4,caller.box.pos.y + caller.box.size.y);
            link.tooltipPos = (posx,posy);
        }
    }
}