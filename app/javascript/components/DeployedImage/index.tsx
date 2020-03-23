import { hot } from 'react-hot-loader';

import _ from 'lodash';
import React from 'react';

import fetch from 'util/fetch';

import NomadStatusData from 'components/NomadStatus/Data';

interface State {
  loading: boolean;
  error: boolean;
  data?: NomadStatusData;
}

interface Props {
  endpoint: string;
}

class DeployedImage extends React.Component<Props, State> {
  public state: State = {
    error: false,
    loading: true,
  };

  public componentDidMount() {
    this.fetchData();
  }

  public render() {
    if (this.state.loading) return null;
    if (this.state.error) return null;

    return <div className='DeployedImage'>Deployed: { this.deployedImage }</div>;
  }

  private get deployedImage() {
    if (!this.state.data) return null;

    if (!this.state.data.detail) {
      return 'nothing';
    }

    return this.state.data.detail.groups[0].tasks[0].config.image;
  }

  private async fetchData() {
    try {
      const data = await fetch(this.props.endpoint);
      const json = await data.json();

      this.setState({ data: json, loading: false });
    } catch (_) {
      this.setState({ error: true, loading: false });
    }
  }
}

export default hot(module)(DeployedImage);
