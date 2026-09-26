# Kanata (Super-Vim keyboard logic) + console

{
  old,
  ...
}:

{
  # Sync TTY font and keyboard layout
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # ==========================================================
  # 3. KANATA (Super-Vim Keyboard Logic)
  # ==========================================================

  services.kanata = {
    enable = true;
    package = old.kanata;
    keyboards.super-vim-final = {
      devices = [ ];
      config = ''
        (defsrc
          lalt ralt q v h j k l s d f g b i o p caps esc menu ' bksl
        )

        (defalias
          l-nav (tap-hold 200 200 lalt (layer-toggle nav))
          r-nav (tap-hold 200 200 ralt (layer-toggle nav))
          
          ;; Sniper mode landing zone: Quote or Backslash
          snipe-qt (tap-hold 200 200 ' (layer-toggle precision))
          snipe-bs (tap-hold 200 200 bksl (layer-toggle precision))
          
          l5 (movemouse-left 5 5)
          u5 (movemouse-up 5 5)
          d5 (movemouse-down 5 5)
          r5 (movemouse-right 5 5)
          
          l1 (movemouse-left 10 1)
          u1 (movemouse-up 10 1)
          d1 (movemouse-down 10 1)
          r1 (movemouse-right 10 1)
          
          m-center (multi lsft f12)
        )

        (deflayer default
          @l-nav @r-nav q v h j k l s d f g b i o p esc caps rctl @snipe-qt @snipe-bs
        )

        (deflayer nav
          ;; Alt + Q = Scroll Up | Alt + V = Scroll Down
          _ _ (mwheel-up 50 120) (mwheel-down 50 120) left down up rght @l5 @u5 @d5 @r5 @m-center mlft mmid mrgt _ _ _ _ _
        )

        (deflayer precision
          ;; Precision mouse movement on s/d/f/g
          _ _ _ _ _ _ _ _ @l1 @u1 @d1 @r1 _ mlft mmid mrgt _ _ _ _ _
        )
      '';
    };
  };
}
