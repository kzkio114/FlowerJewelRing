// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import VisibilityController from "./visibility_controller"
application.register("visibility", VisibilityController)

import MyCustomName from "./rendering_controller"
application.register("rendering", MyCustomName)

import ModalController from "./modal_controller"
application.register("modal", ModalController)

//import TooltipController from "./tooltip_controller"
//application.register("tooltip", TooltipController) // 'tooltip' で登録

import HelloController from "./hello_controller"
application.register("hello", HelloController)
