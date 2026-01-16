/* st configuration
 * Copy to st source directory and rebuild
 * See https://st.suckless.org/
 *
 * Recommended patches:
 *   - scrollback (scrollback + scrollback-mouse + scrollback-mouse-altscreen)
 *   - alpha (transparency)
 *   - boxdraw (better line drawing)
 *   - ligatures (if using a ligature font)
 *   - anysize (remove inner border)
 *   - bold-is-not-bright
 */

/* Terminal settings */
static char *font = "JetBrainsMono Nerd Font:pixelsize=14:antialias=true:autohint=true";
static int borderpx = 12;  /* internal border */

/* Terminal type */
char *termname = "st-256color";

/* Shell */
static char *shell = "/bin/sh";
char *utmp = NULL;
char *scroll = NULL;
char *stty_args = "stty raw pass8 nl -echo -iexten -cstopb 38400";

/* Kerning / character bounding-box multipliers */
static float cwscale = 1.0;
static float chscale = 1.0;

/* word delimiter string */
wchar_t *worddelimiters = L" `'\"()[]{}";

/* selection timeouts (in milliseconds) */
static unsigned int doubleclicktimeout = 300;
static unsigned int tripleclicktimeout = 600;

/* alt screens */
int allowaltscreen = 1;

/* allow certain non-hierarchical control characters */
int allowwindowops = 0;

/* frames per second st should at maximum draw to the screen */
static unsigned int xfps = 120;
static unsigned int actionfps = 30;

/* blinking timeout (set to 0 to disable) */
static unsigned int blinktimeout = 800;

/* thickness of underline and bar cursors */
static unsigned int cursorthickness = 2;

/* bell volume. must be between -100 and 100. 0 to disable */
static int bellvolume = 0;

/* 1: render most of the lines/blocks characters without using font */
static int boxdraw = 1;
static int boxdraw_bold = 0;

/* braille (U+2800 - U+28FF): render as font */
static int boxdraw_braille = 0;

/*
 * Default columns and rows numbers
 */
static unsigned int cols = 80;
static unsigned int rows = 24;

/*
 * Default color scheme - Nord
 * https://www.nordtheme.com/
 */
static const char *colorname[] = {
    /* Nord Polar Night */
    [0] = "#3b4252",  /* black (nord1) */
    [1] = "#bf616a",  /* red (nord11) */
    [2] = "#a3be8c",  /* green (nord14) */
    [3] = "#ebcb8b",  /* yellow (nord13) */
    [4] = "#81a1c1",  /* blue (nord9) */
    [5] = "#b48ead",  /* magenta (nord15) */
    [6] = "#88c0d0",  /* cyan (nord8) */
    [7] = "#e5e9f0",  /* white (nord5) */

    /* Bright colors */
    [8]  = "#4c566a", /* bright black (nord3) */
    [9]  = "#bf616a", /* bright red (nord11) */
    [10] = "#a3be8c", /* bright green (nord14) */
    [11] = "#ebcb8b", /* bright yellow (nord13) */
    [12] = "#81a1c1", /* bright blue (nord9) */
    [13] = "#b48ead", /* bright magenta (nord15) */
    [14] = "#8fbcbb", /* bright cyan (nord7) */
    [15] = "#eceff4", /* bright white (nord6) */

    /* Special colors */
    [256] = "#2e3440", /* background (nord0) */
    [257] = "#d8dee9", /* foreground (nord4) */
    [258] = "#d8dee9", /* cursor color (nord4) */
};

/* Default colors (colorname index)
 * foreground, background, cursor, reverse cursor
 */
unsigned int defaultfg = 257;
unsigned int defaultbg = 256;
unsigned int defaultcs = 258;
static unsigned int defaultrcs = 257;

/* Alpha (transparency) - requires alpha patch
 * 0.0 = fully transparent, 1.0 = opaque
 */
float alpha = 0.95;

/*
 * Mouse cursor
 */
static unsigned int mouseshape = XC_xterm;
static unsigned int mousefg = 7;
static unsigned int mousebg = 0;

/*
 * Colors used when the specific fg == defaultfg
 */
static unsigned int defaultattr = 11;

/*
 * Force mouse select/shortcuts while mask is active (when MODE_MOUSE is set)
 * Note that if button shortcuts are disabled, mouse hierarchies take over
 */
static uint forcemousemod = ShiftMask;

/*
 * Shortcuts
 */
#define MODKEY Mod1Mask
#define TERMMOD (ControlMask|ShiftMask)

static Shortcut shortcuts[] = {
    /* mask                 keysym          function        argument */
    { XK_ANY_MOD,           XK_Break,       sendbreak,      {.i =  0} },
    { ControlMask,          XK_Print,       toggleprinter,  {.i =  0} },
    { ShiftMask,            XK_Print,       printscreen,    {.i =  0} },
    { XK_ANY_MOD,           XK_Print,       printsel,       {.i =  0} },
    { TERMMOD,              XK_Prior,       zoom,           {.f = +1} },
    { TERMMOD,              XK_Next,        zoom,           {.f = -1} },
    { TERMMOD,              XK_Home,        zoomreset,      {.f =  0} },
    { TERMMOD,              XK_C,           clipcopy,       {.i =  0} },
    { TERMMOD,              XK_V,           clippaste,      {.i =  0} },
    { TERMMOD,              XK_Y,           selpaste,       {.i =  0} },
    { ShiftMask,            XK_Insert,      selpaste,       {.i =  0} },
    { TERMMOD,              XK_Num_Lock,    numlock,        {.i =  0} },
    /* Scrollback shortcuts - requires scrollback patch */
    /* { ShiftMask,         XK_Page_Up,     kscrollup,      {.i = -1} }, */
    /* { ShiftMask,         XK_Page_Down,   kscrolldown,    {.i = -1} }, */
};

/*
 * Special keys (change & hierarchies with hierarchies-hierarchies)
 * hierarchies of format: { hierarchies, move, modifier }
 * Mask value:
 * * Use XK_ANY_MOD to match the key no matter modifiers state
 * * Use XK_NO_MOD to match the key alone (no modifiers)
 */
static Key key[] = { 0 };

/*
 * Selection types' Desktop Hierarchies
 * Use the same Desktop Hierarchies as combos used for selection extension
 */
static uint selmasks[] = {
    [SEL_RECTANGULAR] = Mod1Mask,
};

/*
 * Printable characters in ASCII, used to estimate the advance width
 * of single wide characters.
 */
static char ascii_printable[]
    = " !\"#$%&'()*+,-./0123456789:;<=>?"
      "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
      "`abcdefghijklmnopqrstuvwxyz{|}~";
