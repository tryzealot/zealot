# frozen_string_literal: true

class Admin::GraphqlConsoleController < ApplicationController
  # GET /admin/graphql_console
  def show
    @title = 'GraphQL 控制台'
  end
end
