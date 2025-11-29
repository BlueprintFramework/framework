import tw from 'twin.macro';
import { createGlobalStyle } from 'styled-components/macro';

export default createGlobalStyle`
    :root {
      --blueprint-white: 255 255 255;
      --blueprint-black: 19 26 32;

      --blueprint-primary: var(--blueprint-primary-500);
      --blueprint-primary-50: var(--blueprint-blue-50);
      --blueprint-primary-100: var(--blueprint-blue-100);
      --blueprint-primary-200: var(--blueprint-blue-200);
      --blueprint-primary-300: var(--blueprint-blue-300);
      --blueprint-primary-400: var(--blueprint-blue-400);
      --blueprint-primary-500: var(--blueprint-blue-500);
      --blueprint-primary-600: var(--blueprint-blue-600);
      --blueprint-primary-700: var(--blueprint-blue-700);
      --blueprint-primary-800: var(--blueprint-blue-800);
      --blueprint-primary-900: var(--blueprint-blue-900);
      --blueprint-primary-950: var(--blueprint-blue-950);

      --blueprint-neutral: var(--blueprint-neutral-500);
      --blueprint-neutral-50: var(--blueprint-gray-50);
      --blueprint-neutral-100: var(--blueprint-gray-100);
      --blueprint-neutral-200: var(--blueprint-gray-200);
      --blueprint-neutral-300: var(--blueprint-gray-300);
      --blueprint-neutral-400: var(--blueprint-gray-400);
      --blueprint-neutral-500: var(--blueprint-gray-500);
      --blueprint-neutral-600: var(--blueprint-gray-600);
      --blueprint-neutral-700: var(--blueprint-gray-700);
      --blueprint-neutral-800: var(--blueprint-gray-800);
      --blueprint-neutral-900: var(--blueprint-gray-900);
      --blueprint-neutral-950: var(--blueprint-gray-950);

      --blueprint-slate: var(--blueprint-slate-500);
      --blueprint-slate-50: 248 250 252;
      --blueprint-slate-100: 241 245 249;
      --blueprint-slate-200: 226 232 240;
      --blueprint-slate-300: 203 213 225;
      --blueprint-slate-400: 148 163 184;
      --blueprint-slate-500: 100 116 139;
      --blueprint-slate-600: 71 85 105;
      --blueprint-slate-700: 51 65 85;
      --blueprint-slate-800: 30 41 59;
      --blueprint-slate-900: 15 23 42;
      --blueprint-slate-950: 2 6 23;

      --blueprint-gray: var(--blueprint-gray-500);
      --blueprint-gray-50: 245 247 250;
      --blueprint-gray-100: 229 232 235;
      --blueprint-gray-200: 202 209 216;
      --blueprint-gray-300: 154 165 177;
      --blueprint-gray-400: 123 135 147;
      --blueprint-gray-500: 96 109 123;
      --blueprint-gray-600: 81 95 108;
      --blueprint-gray-700: 63 77 90;
      --blueprint-gray-800: 51 64 77;
      --blueprint-gray-900: 31 41 51;
      --blueprint-gray-950: 3 7 18;

      --blueprint-zinc: var(--blueprint-zinc-500);
      --blueprint-zinc-50: 250 250 250;
      --blueprint-zinc-100: 244 244 245;
      --blueprint-zinc-200: 228 228 231;
      --blueprint-zinc-300: 212 212 216;
      --blueprint-zinc-400: 161 161 170;
      --blueprint-zinc-500: 113 113 122;
      --blueprint-zinc-600: 82 82 91;
      --blueprint-zinc-700: 63 63 70;
      --blueprint-zinc-800: 39 39 42;
      --blueprint-zinc-900: 24 24 27;
      --blueprint-zinc-950: 9 9 11;

      --blueprint-stone: var(--blueprint-stone-500);
      --blueprint-stone-50: 250 250 249;
      --blueprint-stone-100: 245 245 244;
      --blueprint-stone-200: 231 229 228;
      --blueprint-stone-300: 214 211 209;
      --blueprint-stone-400: 168 162 158;
      --blueprint-stone-500: 120 113 108;
      --blueprint-stone-600: 87 83 78;
      --blueprint-stone-700: 68 64 60;
      --blueprint-stone-800: 41 37 36;
      --blueprint-stone-900: 28 25 23;
      --blueprint-stone-950: 12 10 9;

      --blueprint-red: var(--blueprint-red-500);
      --blueprint-red-50: 254 242 242;
      --blueprint-red-100: 254 226 226;
      --blueprint-red-200: 254 202 202;
      --blueprint-red-300: 252 165 165;
      --blueprint-red-400: 248 113 113;
      --blueprint-red-500: 239 68 68;
      --blueprint-red-600: 220 38 38;
      --blueprint-red-700: 185 28 28;
      --blueprint-red-800: 153 27 27;
      --blueprint-red-900: 127 29 29;
      --blueprint-red-950: 69 10 10;

      --blueprint-orange: var(--blueprint-orange-500);
      --blueprint-orange-50: 255 247 237;
      --blueprint-orange-100: 255 237 213;
      --blueprint-orange-200: 254 215 170;
      --blueprint-orange-300: 253 186 116;
      --blueprint-orange-400: 251 146 60;
      --blueprint-orange-500: 249 115 22;
      --blueprint-orange-600: 234 88 12;
      --blueprint-orange-700: 194 65 12;
      --blueprint-orange-800: 154 52 18;
      --blueprint-orange-900: 124 45 18;
      --blueprint-orange-950: 67 20 7;

      --blueprint-amber: var(--blueprint-amber-500);
      --blueprint-amber-50: 255 251 235;
      --blueprint-amber-100: 254 243 199;
      --blueprint-amber-200: 253 230 138;
      --blueprint-amber-300: 252 211 77;
      --blueprint-amber-400: 251 191 36;
      --blueprint-amber-500: 245 158 11;
      --blueprint-amber-600: 217 119 6;
      --blueprint-amber-700: 180 83 9;
      --blueprint-amber-800: 146 64 14;
      --blueprint-amber-900: 120 53 15;
      --blueprint-amber-950: 69 26 3;

      --blueprint-yellow: var(--blueprint-yellow-400);
      --blueprint-yellow-50: 254 252 232;
      --blueprint-yellow-100: 254 249 195;
      --blueprint-yellow-200: 254 240 138;
      --blueprint-yellow-300: 253 224 71;
      --blueprint-yellow-400: 250 204 21;
      --blueprint-yellow-500: 234 179 8;
      --blueprint-yellow-600: 202 138 4;
      --blueprint-yellow-700: 161 98 7;
      --blueprint-yellow-800: 133 77 14;
      --blueprint-yellow-900: 113 63 18;
      --blueprint-yellow-950: 66 32 6;

      --blueprint-lime: var(--blueprint-lime-400);
      --blueprint-lime-50: 247 254 231;
      --blueprint-lime-100: 236 252 203;
      --blueprint-lime-200: 217 249 157;
      --blueprint-lime-300: 190 242 100;
      --blueprint-lime-400: 163 230 53;
      --blueprint-lime-500: 132 204 22;
      --blueprint-lime-600: 101 163 13;
      --blueprint-lime-700: 77 124 15;
      --blueprint-lime-800: 63 98 18;
      --blueprint-lime-900: 54 83 20;
      --blueprint-lime-950: 26 46 5;

      --blueprint-green: var(--blueprint-green-500);
      --blueprint-green-50: 240 253 244;
      --blueprint-green-100: 220 252 231;
      --blueprint-green-200: 187 247 208;
      --blueprint-green-300: 134 239 172;
      --blueprint-green-400: 74 222 128;
      --blueprint-green-500: 34 197 94;
      --blueprint-green-600: 22 163 74;
      --blueprint-green-700: 21 128 61;
      --blueprint-green-800: 22 101 52;
      --blueprint-green-900: 20 83 45;
      --blueprint-green-950: 5 46 22;

      --blueprint-emerald: var(--blueprint-emerald-500);
      --blueprint-emerald-50: 236 253 245;
      --blueprint-emerald-100: 209 250 229;
      --blueprint-emerald-200: 167 243 208;
      --blueprint-emerald-300: 110 231 183;
      --blueprint-emerald-400: 52 211 153;
      --blueprint-emerald-500: 16 185 129;
      --blueprint-emerald-600: 5 150 105;
      --blueprint-emerald-700: 4 120 87;
      --blueprint-emerald-800: 6 95 70;
      --blueprint-emerald-900: 6 78 59;
      --blueprint-emerald-950: 2 44 34;

      --blueprint-teal: var(--blueprint-teal-500);
      --blueprint-teal-50: 240 253 250;
      --blueprint-teal-100: 204 251 241;
      --blueprint-teal-200: 153 246 228;
      --blueprint-teal-300: 94 234 212;
      --blueprint-teal-400: 45 212 191;
      --blueprint-teal-500: 20 184 166;
      --blueprint-teal-600: 13 148 136;
      --blueprint-teal-700: 15 118 110;
      --blueprint-teal-800: 17 94 89;
      --blueprint-teal-900: 19 78 74;
      --blueprint-teal-950: 4 47 46;

      --blueprint-cyan: var(--blueprint-cyan-400);
      --blueprint-cyan-50: 236 254 255;
      --blueprint-cyan-100: 207 250 254;
      --blueprint-cyan-200: 165 243 252;
      --blueprint-cyan-300: 103 232 249;
      --blueprint-cyan-400: 34 211 238;
      --blueprint-cyan-500: 6 182 212;
      --blueprint-cyan-600: 8 145 178;
      --blueprint-cyan-700: 14 116 144;
      --blueprint-cyan-800: 21 94 117;
      --blueprint-cyan-900: 22 78 99;
      --blueprint-cyan-950: 8 51 68;

      --blueprint-sky: var(--blueprint-sky-400);
      --blueprint-sky-50: 240 249 255;
      --blueprint-sky-100: 224 242 254;
      --blueprint-sky-200: 186 230 253;
      --blueprint-sky-300: 125 211 252;
      --blueprint-sky-400: 56 189 248;
      --blueprint-sky-500: 14 165 233;
      --blueprint-sky-600: 2 132 199;
      --blueprint-sky-700: 3 105 161;
      --blueprint-sky-800: 7 89 133;
      --blueprint-sky-900: 12 74 110;
      --blueprint-sky-950: 8 47 73;

      --blueprint-blue: var(--blueprint-blue-500);
      --blueprint-blue-50: 239 246 255;
      --blueprint-blue-100: 219 234 254;
      --blueprint-blue-200: 191 219 254;
      --blueprint-blue-300: 147 197 253;
      --blueprint-blue-400: 96 165 250;
      --blueprint-blue-500: 59 130 246;
      --blueprint-blue-600: 37 99 235;
      --blueprint-blue-700: 29 78 216;
      --blueprint-blue-800: 30 64 175;
      --blueprint-blue-900: 30 58 138;
      --blueprint-blue-950: 23 37 84;

      --blueprint-indigo: var(--blueprint-indigo-400);
      --blueprint-indigo-50: 238 242 255;
      --blueprint-indigo-100: 224 231 255;
      --blueprint-indigo-200: 199 210 254;
      --blueprint-indigo-300: 165 180 252;
      --blueprint-indigo-400: 129 140 248;
      --blueprint-indigo-500: 99 102 241;
      --blueprint-indigo-600: 79 70 229;
      --blueprint-indigo-700: 67 56 202;
      --blueprint-indigo-800: 55 48 163;
      --blueprint-indigo-900: 49 46 129;
      --blueprint-indigo-950: 30 27 75;

      --blueprint-violet: var(--blueprint-violet-500);
      --blueprint-violet-50: 245 243 255;
      --blueprint-violet-100: 237 233 254;
      --blueprint-violet-200: 221 214 254;
      --blueprint-violet-300: 196 181 253;
      --blueprint-violet-400: 167 139 250;
      --blueprint-violet-500: 139 92 246;
      --blueprint-violet-600: 124 58 237;
      --blueprint-violet-700: 109 40 217;
      --blueprint-violet-800: 91 33 182;
      --blueprint-violet-900: 76 29 149;
      --blueprint-violet-950: 46 16 101;

      --blueprint-purple: var(--blueprint-purple-600);
      --blueprint-purple-50: 245 243 255;
      --blueprint-purple-100: 243 232 255;
      --blueprint-purple-200: 233 213 255;
      --blueprint-purple-300: 216 180 254;
      --blueprint-purple-400: 192 132 252;
      --blueprint-purple-500: 168 85 247;
      --blueprint-purple-600: 147 51 234;
      --blueprint-purple-700: 126 34 206;
      --blueprint-purple-800: 107 33 168;
      --blueprint-purple-900: 88 28 135;
      --blueprint-purple-950: 59 7 100;

      --blueprint-fuchsia: var(--blueprint-fuchsia-500);
      --blueprint-fuchsia-50: 253 244 255;
      --blueprint-fuchsia-100: 250 232 255;
      --blueprint-fuchsia-200: 245 208 254;
      --blueprint-fuchsia-300: 240 171 252;
      --blueprint-fuchsia-400: 232 121 249;
      --blueprint-fuchsia-500: 217 70 239;
      --blueprint-fuchsia-600: 192 38 211;
      --blueprint-fuchsia-700: 162 28 175;
      --blueprint-fuchsia-800: 134 25 143;
      --blueprint-fuchsia-900: 112 26 117;
      --blueprint-fuchsia-950: 74 4 78;

      --blueprint-pink: var(--blueprint-pink-500);
      --blueprint-pink-50: 253 242 248;
      --blueprint-pink-100: 252 231 243;
      --blueprint-pink-200: 251 207 232;
      --blueprint-pink-300: 249 168 212;
      --blueprint-pink-400: 244 114 182;
      --blueprint-pink-500: 236 72 153;
      --blueprint-pink-600: 219 39 119;
      --blueprint-pink-700: 190 24 93;
      --blueprint-pink-800: 157 23 77;
      --blueprint-pink-900: 131 24 67;
      --blueprint-pink-950: 80 7 36;

      --blueprint-rose: var(--blueprint-rose-500);
      --blueprint-rose-50: 255 241 242;
      --blueprint-rose-100: 255 228 230;
      --blueprint-rose-200: 254 205 211;
      --blueprint-rose-300: 253 164 175;
      --blueprint-rose-400: 251 113 133;
      --blueprint-rose-500: 244 63 94;
      --blueprint-rose-600: 225 29 72;
      --blueprint-rose-700: 190 18 60;
      --blueprint-rose-800: 159 18 57;
      --blueprint-rose-900: 136 19 55;
      --blueprint-rose-950: 76 5 25;
    }

    body {
        ${tw`font-sans bg-neutral-800 text-neutral-200`};
        letter-spacing: 0.015em;
    }

    h1, h2, h3, h4, h5, h6 {
        ${tw`font-medium tracking-normal font-header`};
    }

    p {
        ${tw`text-neutral-200 leading-snug font-sans`};
    }

    form {
        ${tw`m-0`};
    }

    textarea, select, input, button, button:focus, button:focus-visible {
        ${tw`outline-none`};
    }

    input[type=number]::-webkit-outer-spin-button,
    input[type=number]::-webkit-inner-spin-button {
        -webkit-appearance: none !important;
        margin: 0;
    }

    input[type=number] {
        -moz-appearance: textfield !important;
    }

    /* Scroll Bar Style */
    ::-webkit-scrollbar {
        background: none;
        width: 16px;
        height: 16px;
    }

    ::-webkit-scrollbar-thumb {
        border: solid 0 rgb(0 0 0 / 0%);
        border-right-width: 4px;
        border-left-width: 4px;
        -webkit-border-radius: 9px 4px;
        -webkit-box-shadow: inset 0 0 0 1px hsl(211, 10%, 53%), inset 0 0 0 4px hsl(209deg 18% 30%);
    }

    ::-webkit-scrollbar-track-piece {
        margin: 4px 0;
    }

    ::-webkit-scrollbar-thumb:horizontal {
        border-right-width: 0;
        border-left-width: 0;
        border-top-width: 4px;
        border-bottom-width: 4px;
        -webkit-border-radius: 4px 9px;
    }

    ::-webkit-scrollbar-corner {
        background: transparent;
    }
`;
