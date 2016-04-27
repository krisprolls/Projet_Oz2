functor
import
   Module
   OS
export
   StartGame
define
   [QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

   Canvas
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   WidthCell=40
   HeightCell=40
   NW=20
   NH=20
   W =WidthCell*NW
   H =HeightCell*NH
   Command
   CommandPort = {NewPort Command}
   Desc=td(canvas(bg:black
                  width:W
                  height:H
                  handle:Canvas))
   Window={QTk.build Desc}
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   proc{DrawBox Color X Y}
      case Color of white then
	 {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PacManImg)}
      else
	 {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:Color outline:black)}
      end
   end
   proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawHline X1+HeightCell Y1 X2+HeightCell Y2}
	 end
      end
      proc{DrawVline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawVline X1 Y1+WidthCell X2 Y2+WidthCell}
	 end
      end
      proc{DrawUnits L}
	 case L of r(Color X Y)|T then
	    {DrawBox Color X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in
      {DrawHline 0 0 0 W}
      {DrawVline 0 0 W 0}
      {DrawUnits ListToDraw}
   end
   proc{Game MySelf Ghosts Command}
      MyNewState
      NextCommand
      GhostNewStates
      GhostNewStates1
      fun {MoveTo Movement OldState}
	 NewX NewY DX DY OldX OldY Color  in
	 r(Color OldX OldY) = OldState
	 r(DX DY) = Movement
	 NewX = OldX + DX
	 NewY = OldY + DY
	 {DrawBox black OldX OldY}
	 {DrawBox Color NewX NewY}
	 r(Color NewX NewY)
      end
      fun {UserCommand Command OldState NewState}
	 case Command of r(DX DY)|T then
	    NewState = {MoveTo r(DX DY) OldState}
	    T
	 end
      end
      fun {MoveAll OldState NewState}
	 Dir
         in
	 case OldState
	 of Old|T then
	    Dir = {Int.'mod' {OS.rand} 4}
	    case Dir of 0 then
	       {MoveAll T {MoveTo r(~1 0) Old}|NewState}
	       [] 1 then {MoveAll T  {MoveTo r(0 1) Old}|NewState}
	       [] 2 then {MoveAll T  {MoveTo r(1 0) Old}|NewState}
	       [] 3 then {MoveAll T  {MoveTo r(0 ~1) Old}|NewState}
	    end
	 [] nil then  NewState
	 end
      end
   in
      NextCommand = {UserCommand Command MySelf MyNewState}
      GhostNewStates = {MoveAll Ghosts nil}
      GhostNewStates1 = {MoveAll GhostNewStates nil}
      {Game MyNewState GhostNewStates1 NextCommand}
   end
   
   proc {StartGame}
      MySelf
      Ghosts
   in
      %{Browse show}
      {Window show}
      %{Browse aftershow}
      %Initialize ghosts and user
      MySelf = r(white 8 8)
      Ghosts = [r(yellow 1 12) r(blue 10 3) r(green 11 10)]
      {InitLayout MySelf|Ghosts}
      {Game MySelf Ghosts Command}
   end
end
