(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`Chatbook`PersonaManager`" ];

(* :!CodeAnalysis::BeginBlock:: *)

`CreatePersonaManagerDialog;
`CreatePersonaManagerPanel;

(* TODO: create a Dialogs.wl file containing definitions to share between this and the persona dialog *)

Begin[ "`Private`" ];

Needs[ "Wolfram`Chatbook`"                   ];
Needs[ "Wolfram`Chatbook`Common`"            ];
Needs[ "Wolfram`Chatbook`Personas`"          ];
Needs[ "Wolfram`Chatbook`UI`"                ];
Needs[ "Wolfram`Chatbook`Dialogs`"           ];
Needs[ "Wolfram`Chatbook`ResourceInstaller`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$chatbookDocumentationURL = "https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/Chatbook";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreatePersonaManagerDialog*)
CreatePersonaManagerDialog // beginDefinition;

CreatePersonaManagerDialog[ args___ ] := createDialog[
    CreatePersonaManagerPanel @ args,
    WindowTitle -> "Add & Manage Personas"
];

CreatePersonaManagerDialog // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreatePersonaManagerPanel*)
CreatePersonaManagerPanel // beginDefinition;

CreatePersonaManagerPanel[ ] := DynamicModule[{favorites, delimColor},
    favorites =
        Replace[
            CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "PersonaFavorites"}],
            Except[{___String}] :> $corePersonaNames];

    Framed[
        Grid[
            {
                {
                    Pane[
                        Style["Add & Manage Personas", "DialogHeader"],
                        FrameMargins -> Dynamic[CurrentValue[{StyleDefinitions, "DialogHeader", CellMargins}]],
                        ImageSize -> {501, Automatic}]},
                {
                    Pane[
                        Dynamic[
                            StringTemplate["`n1` personas being shown in the prompt menu. `n2` total personas available."][
                                <|
                                    "n1" -> If[ListQ[#], Length[#], "\[LongDash]"]&[CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}]],
                                    "n2" -> If[Length[#] > 0, Length[#], "\[LongDash]"]&[$CachedPersonaData]|>],
                            TrackedSymbols :> {$CachedPersonaData}],
                        BaseStyle -> "DialogBody",
                        FrameMargins -> Dynamic[Replace[CurrentValue[{StyleDefinitions, "DialogBody", CellMargins}], {{l_, r_}, {b_, t_}} :> {{l, r}, {0, t}}]]]},
                {
                    Pane[
                        Grid[{{
                            "Install from",
                            Button[
                                NotebookTools`Mousedown[
                                    Framed["Prompt Repository", BaseStyle -> "ButtonGray1Normal", BaselinePosition -> Baseline],
                                    Framed["Prompt Repository", BaseStyle -> "ButtonGray1Hover", BaselinePosition -> Baseline],
                                    Framed["Prompt Repository", BaseStyle -> "ButtonGray1Pressed", BaselinePosition -> Baseline],
                                    BaseStyle -> "DialogTextBasic"],
                                ResourceInstallFromRepository[ "Prompt" ],
                                Appearance -> "Suppressed", BaselinePosition -> Baseline, Method -> "Queued"],
                            Button[
                                NotebookTools`Mousedown[
                                    Framed["URL", BaseStyle -> "ButtonGray1Normal", BaselinePosition -> Baseline],
                                    Framed["URL", BaseStyle -> "ButtonGray1Hover", BaselinePosition -> Baseline],
                                    Framed["URL", BaseStyle -> "ButtonGray1Pressed", BaselinePosition -> Baseline],
                                    BaseStyle -> "DialogTextBasic"],
                                Block[ { PrintTemporary }, ResourceInstallFromURL[ "Prompt" ] ],
                                Appearance -> "Suppressed", BaselinePosition -> Baseline, Method -> "Queued"](* ,
                            (* FIXME: FUTURE *)
                            Button[
                                NotebookTools`Mousedown[
                                    Framed["File", BaseStyle -> "ButtonGray1Normal", BaselinePosition -> Baseline],
                                    Framed["File", BaseStyle -> "ButtonGray1Hover", BaselinePosition -> Baseline],
                                    Framed["File", BaseStyle -> "ButtonGray1Pressed", BaselinePosition -> Baseline],
                                    BaseStyle -> "DialogTextBasic"],
                                If[AssociationQ[PersonaInstallFromFile[]], GetPersonaData[]],
                                Appearance -> "Suppressed", BaselinePosition -> Baseline, Method -> "Queued"] *)}}],
                        BaseStyle -> "DialogBody",
                        FrameMargins -> Dynamic[Replace[CurrentValue[{StyleDefinitions, "DialogBody", CellMargins}], {{l_, r_}, {b_, t_}} :> {{l, r}, {15, 5}}]]]},
                {
                    Pane[#, AppearanceElements -> None, ImageSize -> {Full, UpTo[300]}, Scrollbars -> {False, Automatic}]& @
                    Dynamic[
                        Grid[
                            Prepend[
                                KeyValueMap[
                                    formatPersonaData[#1, #2]&,
                                    Join[
                                        KeyTake[$CachedPersonaData, favorites],
                                        KeySort[$CachedPersonaData]]],
                                {"", "In Menu", "", "Name", ""(*FITME*), (*"Description",*) "Version", ""}],
                            Alignment -> {{Center, Center, {Left}}, Center},
                            Background -> {{}, {RGBColor["#e5e5e5"]}},
                            BaseStyle -> "DialogBody",
                            Dividers -> Dynamic @ {
                                {},
                                {
                                    {{True}},
                                    {
                                        2 -> False,
                                        Length[favorites] + 2 -> Directive[delimColor, AbsoluteThickness[5]]}}},
                            FrameStyle -> Dynamic[delimColor],
                            ItemSize -> {{Automatic, Automatic, Automatic, Automatic, Fit, {Automatic}}, {}},
                            Spacings -> {
                                {{{1}}, {2 -> 1, 4 -> 0.5}},
                                0.5}],
                        TrackedSymbols :> {$CachedPersonaData}]},
                {
                    Item[
                        Button[(* give Default properties using specific FEExpression *)
                            NotebookTools`Mousedown[
                                Framed["OK", BaseStyle -> "ButtonRed1Normal", BaselinePosition -> Baseline],
                                Framed["OK", BaseStyle -> "ButtonRed1Hover", BaselinePosition -> Baseline],
                                Framed["OK", BaseStyle -> "ButtonRed1Pressed", BaselinePosition -> Baseline],
                                BaseStyle -> "DialogTextBasic"],
                            DialogReturn @ channelCleanup[ ],
                            Appearance -> FEPrivate`FrontEndResource["FEExpressions", "DefaultSuppressMouseDownNinePatchAppearance"],
                            ImageMargins -> {{0, 31}, {14, 14}},
                            ImageSize -> Automatic ],
                        Alignment -> {Right, Center}]}},
            Alignment -> Left,
            BaseStyle -> {FontSize -> 1}, (* useful setting in case we want fixed-width columns; ItemSize would scale at the same rate as ImageSize *)
            Dividers -> {{}, {2 -> True, 4 -> Directive[delimColor, AbsoluteThickness[5]], -2 -> Directive[delimColor, AbsoluteThickness[5]]}},
            FrameStyle -> Dynamic[delimColor],
            Spacings -> {0, 0}],
        ContentPadding -> 0,
        FrameMargins -> -1,
        FrameStyle -> None,
        ImageSize -> {501, All}],
    Initialization :> (
        delimColor = CurrentValue[{StyleDefinitions, "DialogDelimiter", CellFrameColor}];
        GetPersonaData[]; (* sets $CachedPersonaData *)
        (* make sure there are no unexpected extra personas *)
        CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}] =
            Intersection[
                CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}],
                Keys[$CachedPersonaData]]),
    Deinitialization :> (CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "PersonaFavorites"}] = favorites)
];

CreatePersonaManagerPanel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatPersonaData*)
formatPersonaData // beginDefinition;

formatPersonaData[ name_String, as_Association ] :=
    formatPersonaData[
        name,
        as,
        as[ "DocumentationLink" ],
        as[ "Description" ],
        as[ "Version" ],
        getPersonaIcon @ as,
        as[ "Origin" ],
        as[ "PacletName" ]
    ];

formatPersonaData[
    name_String,
    as_Association,
    link_,
    desc_,
    version_,
    KeyValuePattern[ "Default" -> icon_ ],
    origin_,
    pacletName_
] :=
    formatPersonaData[ name, as, link, desc, version, icon, origin, pacletName ];

formatPersonaData[ name_String, as_Association, link_, desc_, version_, icon_, origin_, pacletName_ ] := {
    formatPacletLink[ origin, link, pacletName ],
    addRemovePersonaListingCheckbox[ name ],
    formatIcon @ icon,
    formatName[ origin, personaDisplayName @ name, link ],
    "", (* used for Grid's ItemSize -> Fit *)
    (* formatDescription @ desc, *) (* not enough room for a fixed-width dialog where the "Name" column can be quite large *)
    formatVersion @ version,
    Which[
        FileExistsQ @ ResourceInstallLocation[ "Prompt", name ], uninstallButton[ name, True, "\[LongDash]" ],
        MissingQ[origin], uninstallButton[ name, False, "\[LongDash]" ],
        origin === "LocalPaclet", uninstallButton[ name, False, pacletName ],
        origin === "Wolfram/Chatbook", uninstallButton[ name, False, origin ] ]
};

formatPersonaData // endDefinition;

formatName // beginDefinition;
formatName[ name_String ] := StringJoin[ Riffle[ DeleteCases[ StringTrim @ StringSplit[ name, RegularExpression[ "([A-Z])([a-z]+)" ] -> "$1$2 " ], "" ], " " ] ]
formatName[ origin_String, name_String, link_Missing ] :=  formatName[ name ]
formatName[ "PacletRepository", name_String, link_ ] := formatName[ name ]
formatName[ origin_String, name_String, link_ ] :=
    Hyperlink[
        Mouseover[
            Grid[{{formatName[ name ], chatbookIcon["PeelOff", False]}}],
            Grid[{{formatName[ name ], chatbookIcon["PeelOff-hover", False]}}]],
        link,
        BaseStyle -> {LineBreakWithin -> False}];
formatName // endDefinition;

formatDescription // beginDefinition;
formatDescription[ _Missing ] := Style["\[LongDash]", FontColor -> GrayLevel[0.808]];
formatDescription[ desc_String ] :=
    Pane[(* If desc becomes a text resource then use FEPrivate`TruncateStringToWidth *)
        If[StringLength[desc] > #nChars, StringTake[desc, UpTo[#nChars - 2]] <> "\[Ellipsis]", desc],
        ImageSize -> {Full, Automatic},
        ImageSizeAction -> "Clip"
    ]&[<|"nChars" -> 30|>];
formatDescription // endDefinition;

formatVersion // beginDefinition;
formatVersion[ _Missing ] := Style["\[LongDash]", FontColor -> GrayLevel[0.808]];
formatVersion[ version: _String|None ] := version;
formatVersion // endDefinition;

formatIcon // beginDefinition;
formatIcon[ _Missing ] := "";
formatIcon[ KeyValuePattern[ "Default" -> icon_ ] ] := formatIcon @ icon;
formatIcon[ icon_ ] := Pane[ icon, ImageSize -> { 20, 20 }, ImageSizeAction -> "ShrinkToFit" ];
formatIcon // endDefinition;

formatPacletLink // beginDefinition;
formatPacletLink[ origin_String, url_, pacletName_ ] :=
    Switch[origin,
        "Wolfram/Chatbook",
            Tooltip[
                Hyperlink[
                    formatIcon @ Mouseover[chatbookIcon["PacletRepo", False], chatbookIcon["PacletRepo-hover", False]],
                    $chatbookDocumentationURL,
                    ImageMargins -> {{13, 0}, {0, 0}}],
                "Persona installed from the Wolfram/Chatbook paclet. Visit page \[RightGuillemet]"],
        "PacletRepository",
            Tooltip[
                Hyperlink[
                    formatIcon @ Mouseover[chatbookIcon["PacletRepo", False], chatbookIcon["PacletRepo-hover", False]],
                    url,
                    ImageMargins -> {{13, 0}, {0, 0}}],
                StringTemplate["Persona installed from the `name` paclet. Visit page \[RightGuillemet]."][<|"name" -> pacletName|>]],
        _,
            ""];
formatPacletLink // endDefinition;

addRemovePersonaListingCheckbox // beginDefinition;
addRemovePersonaListingCheckbox[ name_String ] :=
    DynamicModule[{val},
        Checkbox[
            Dynamic[val,
                Function[
                    val = #;
                    CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}] =
                        If[#,
                            Union[Replace[CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}], Except[{___String}] :> {}], {name}]
                            ,
                            DeleteCases[CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}], name]]]]],
        Initialization :> (val = MemberQ[CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "Chatbook", "VisiblePersonas"}], name])];
addRemovePersonaListingCheckbox // endDefinition;

uninstallButton // beginDefinition;
uninstallButton[ name_String, installedQ_, pacletName_String ] :=
    Button[
        PaneSelector[
            {
                "Default" -> formatIcon @ chatbookIcon["Delete", False],
                "Hover" -> formatIcon @ chatbookIcon["Delete-hover", False],
                "Disabled" ->
                    Tooltip[
                        formatIcon @ chatbookIcon["Delete-disabled", False],
                        StringTemplate["This persona cannot be uninstalled because it is provided by the `1` paclet."][pacletName]]},
            Dynamic[Which[!installedQ, "Disabled", CurrentValue["MouseOver"], "Hover", True, "Default"]],
            ImageSize -> Automatic],
        Block[ { PrintTemporary }, ResourceUninstall[ "Prompt", name ]; GetPersonaData[] ],
        Appearance -> "Suppressed",
        Enabled -> installedQ,
        ImageMargins -> {{0, 13}, {0, 0}},
        Method -> "Queued" ];
uninstallButton // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
If[ Wolfram`ChatbookInternal`$BuildingMX,
    Null;
];

(* :!CodeAnalysis::EndBlock:: *)

End[ ];
EndPackage[ ];
