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
    Vector2 tooltippos;
    Vector2 tooltipsize;

    String title;
    String iname;
    String remark;
    String shortdesc;
    String longdesc;

    Array<LegendItem> items;

    override void Init (Menu parent) {
        Super.init(parent);

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

        let baseres = (640,480);
        setBaseResolution(baseres);

        int padding = 4;
        bgpos = (padding,padding);
        bgsize = (baseres.x-padding,baseres.y-padding);

        fnt = OptionFont();
        bigfnt = Font.GetFont("DBIGFONT");

        namecolor = Font.CR_RED;
        remarkcolor = Font.CR_DARKGRAY;
        basecolor = Font.CR_WHITE;
        
        tooltipsize = (200,40);

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

        LegendZFLabel titleLabel = LegendZFLabel.Create (
            (bgpos.x+1,bgpos.y+bigfnt.GetHeight()),
            (0,bigfnt.GetHeight()),
            text: "Items",
            fnt: bigfnt,
            wrap: false,
            autosize: true,
            textColor: namecolor
        );

        titleLabel.pack(mainFrame);

        for (int i = 0; i < items.size(); i++) {
            let tx = LegendZFBoxTextures.CreateSingleTexture(items[i].invicon, true);
            let ibtn = LegendZFButton.Create (
                (listpos.x + i * 64,listpos.y), // TODO: Wrapping
                (64,64),
                command: String.format("%d",i),
                inactive: tx,
                hover: tx,
                click: tx
            );
            ibtn.pack(mainFrame);
        }

        if (displayTooltip) {
            console.printf("Showing tooltip...");
            // Build a tooltip!
            let height = fnt.GetHeight();
            let tooltip = LegendZFFrame.Create(
                tooltippos,
                tooltipsize
            );
            // Background...
            LegendZFBoxImage.Create (
                (0,0),
                (200,40),
                btex,
                (1,1)
            ).pack(tooltip);

            // Item name...
            LegendZFLabel.Create (
                (1,1),
                (0,height),
                text: iname,
                fnt: fnt,
                wrap: false,
                autosize:true,
                textColor:namecolor
            ).pack(tooltip);

            // Item remark...
            LegendZFLabel.Create (
                (1,1+height),
                (0,height),
                text: remark,
                fnt: fnt,
                wrap: false,
                autosize:true,
                textColor:remarkcolor
            ).pack(tooltip);

            // Item description...
            LegendZFLabel.Create(
                (1,1+(2*height)),
                (200,40-(2*height)),
                text: shortdesc,
                fnt: fnt,
                wrap: true,
                textColor:basecolor
            ).pack(tooltip);

            tooltip.pack(mainFrame);
        }
    }
}

class ItemMenuHandler : LegendZFHandler {
    ItemMenu link;

    // override void ElementHoverChanged(Element caller, string cmd, bool unhover) {
    //     let l = ItemMenu(link);
    //     l.displayTooltip = !unhover;
    //     if (!unhover) {
    //         int idx = cmd.toInt();
    //         l.iname = l.items[idx].GetTag();
    //         l.remark = l.items[idx].GetRemark();
    //         l.shortdesc = l.items[idx].GetShortDesc();
    //     }
    // }
    // Until I can get THAT working...

    override void buttonClickCommand(LegendZFButton caller, string cmd) {
        console.printf("Button clicked.");
        link.displayTooltip = !link.displayTooltip;
        if (link.displayTooltip) {
            int idx = cmd.toInt();
            link.tooltipPos = (link.listpos.x + idx * 64,link.listpos.y); // TODO: Wrapping
            link.iname = link.items[idx].GetTag();
            link.remark = link.items[idx].GetRemark();
            link.shortdesc = link.items[idx].GetShortDesc();
        }
    }
}