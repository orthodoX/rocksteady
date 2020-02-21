import { hot } from 'react-hot-loader';

import _ from 'lodash';
import React from 'react';

import fetch from 'util/fetch';

interface NomadStatusProps {
  endpoint: string;
}

interface NomadStatusState {
  loading: boolean;
  error: boolean;
  data?: NomadStatusData;
}

interface NomadStatusData {
  detail: {
    groups: any[],
  };
  summary: {
    status: string,
    allocations: { [s: string]: number },
  };
}

class NomadStatus extends React.Component<NomadStatusProps, NomadStatusState> {
  public state: NomadStatusState = {
    error: false,
    loading: true,
  };

  public componentDidMount() {
    this.fetchData();
  }

  public render() {
    return (
      <div className='NomadStatus'>
        { this.state.loading ? this.loadingMessage : this.content }
      </div>
    );
  }

  private get loadingMessage() {
    return <div className='NomadStatus-loadingMessage alert alert-secondary'>Loading Nomad status…</div>;
  }

  private get content() {
    if (this.state.error || !this.state.data) return this.errorMessage;

    return (
      <div>
        { this.state.data.detail ? this.summary : this.notDeployedMessage }
      </div>
    );
  }

  private get errorMessage() {
    return <div className='NomadStatus-errorMessage alert alert-danger'>Error fetching data from Nomad.</div>;
  }

  private get notDeployedMessage() {
    return <div className='NomadStatus-notDeployedMessage alert alert-warning'>App is not deployed.</div>;
  }

  private get summary() {
    if (!this.state.data) return this.errorMessage;

    return (
      <div>
        <dl>
          <dt>Nomad job status</dt>
          <dd>{ this.state.data.summary.status }</dd>
          <dt>Deployed image</dt>
          <dd>{ this.deployedImage }</dd>
        </dl>
      </div>
    );
  }

  private get deployedImage() {
    if (!this.state.data) return this.errorMessage;

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

export default hot(module)(NomadStatus);
export { NomadStatusProps, NomadStatusData };
